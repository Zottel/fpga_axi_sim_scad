#include <array>
#include <cstdlib>
#include <deque>
#include <iostream>
#include <iomanip>
#include <iterator>
#include <memory>
#include <random>
#include <string>
#include <vector>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "argh.hpp"
#include "mio.hpp"

#include "Vinsert_module_name_here.h"

// Global time counter. Needed for sc_time_stamp.
vluint64_t main_time = 0;
double sc_time_stamp() { return main_time; } // Called by $time in Verilog

using RandomGen = std::minstd_rand0;

// Minimal wrapper around pseudo-random generator.
//
// Allows me to set random chance for delays in one place.
class RandomChance {
	private:
		uint_fast32_t divisor;
		RandomGen generator;
	public:
		RandomChance(uint_fast32_t divisor, uint_fast32_t random_seed)
		: generator(random_seed), divisor(divisor) { }
		
		bool operator()() {
			if (divisor > 0) {
				return !(generator() % divisor);
			} else {
				return true;
			}
		}
};

// Manages Vitis control interface.
//
// Essentially has three tasks:
// - Write software parameters to simulated core parameter registers.
// - Start execution by writing to the corresponding control register.
// - Poll control register for "done" signal.
//
class VITIS_CTRL {
	public:
		enum AXI_RESP {
			AXI_OKAY = 0, AXI_EXOKAY = 1, AXI_SLVERR = 2, AXI_DECERR = 3
		};
	
	private:
		bool debug = false;
		std::unique_ptr<RandomChance> random;
		
		bool running = false;
		bool done = false;
		
		uint8_t last_clock = 1;
		
		struct tAW { uint64_t AWADDR; };
		std::deque<tAW> awQueue;
		std::deque<tAW> awQueue_delayed;
		
		struct tW { uint32_t WDATA; uint64_t WSTRB; };
		std::deque<tW> wQueue;
		std::deque<tW> wQueue_delayed;
		
		struct tAR { uint64_t ARADDR; };
		std::deque<tAR> arQueue;
		std::deque<tAR> arQueue_delayed;
		
		struct tR { uint8_t RRESP; uint32_t RDATA; };
		std::deque<tR> rQueue;
		std::deque<tR> rQueue_delayed;
		
		struct tB { uint8_t BRESP; };
		std::deque<tB> bQueue;
		std::deque<tB> bQueue_delayed;
		
	
	public:
		VITIS_CTRL(argh::parser cmdl, std::unique_ptr<RandomChance> random)
			: random(std::move(random)) {
			this->debug = cmdl[{ "-d", "--debug" }];
		}
			
		bool isDone() {
			return this->done;
		}
		
		void start(std::vector<uint32_t> args) {
			assert(!this->running || this->done);
			
			// Enqueue writes for all arguments.
			for (uint32_t i = 0; i < args.size(); i++) {
				awQueue.push_back({(i*8) + 0x10});
				wQueue.push_back({args[i], 0x0f});
			}
			
			// Then tell the kernel to start.
			awQueue.push_back({0});
			wQueue.push_back({0x0001, 0x0f});
			
			this->running = false;
			this->done = false;
		}
		
		void eval(Vinsert_module_name_here & sys) {
			// Only apply and change signals on positive clock edge.
			if (!(!last_clock && sys.ap_clk)) {
				last_clock = sys.ap_clk;
				return; // Only apply once per cycle.
			} else {
				last_clock = sys.ap_clk;
			}
			
			if (debug)
				std::cout << "ctrl eval()" << std::endl;
			
			// Incoming channels.
			inRead(sys.s_axi_control_RVALID, sys.s_axi_control_RREADY,
			       sys.s_axi_control_RDATA, sys.s_axi_control_RRESP);
			inWriteResp(sys.s_axi_control_BVALID, sys.s_axi_control_BREADY,
			            sys.s_axi_control_BRESP);
			
			// Decide delays of input channels.
			if (rQueue.size() && (*random)()) {
				rQueue_delayed.emplace_back(rQueue.front());
				rQueue.pop_front();
			}
			if (bQueue.size() && (*random)()) {
				bQueue_delayed.emplace_back(bQueue.front());
				bQueue.pop_front();
			}
			
			// Apply operations from C++ queues.
			memoryOps();
			
			// Decide delays of input channels.
			if (awQueue.size() && (*random)()) {
				awQueue_delayed.emplace_back(awQueue.front());
				awQueue.pop_front();
			}
			if (wQueue.size() && (*random)()) {
				wQueue_delayed.emplace_back(wQueue.front());
				wQueue.pop_front();
			}
			if (arQueue.size() && (*random)()) {
				arQueue_delayed.emplace_back(arQueue.front());
				arQueue.pop_front();
			}
			
			// Outgoing channels.
			outWriteAddress(sys.s_axi_control_AWVALID, sys.s_axi_control_AWREADY,
			                sys.s_axi_control_AWADDR);
			outWrite(sys.s_axi_control_WVALID, sys.s_axi_control_WREADY,
			         sys.s_axi_control_WDATA, sys.s_axi_control_WSTRB);
			outReadAddress(sys.s_axi_control_ARVALID, sys.s_axi_control_ARREADY,
			               sys.s_axi_control_ARADDR);
			
		}
		
	private:
		void memoryOps() {
			if (!arQueue.size() && !awQueue.size() && !wQueue.size()
			    && !arQueue_delayed.size() && !awQueue_delayed.size() && !wQueue_delayed.size()) {
				arQueue.push_back({0}); // Poll kernel status.
			}
			
			if (rQueue_delayed.size()) {
				auto & r = rQueue_delayed.front();
				if (r.RRESP == AXI_OKAY) {
					if ((r.RDATA & 0x2) && !this->done) {
						this->done = true;
						std::cout << "Kernel is done!" << std::endl;
					}
				} else {
					std::cout << "VITIS_CTRL returned read error: "
					          << "RRESP: " << (uint64_t) r.RRESP
					          << std::endl;
				}
				rQueue_delayed.pop_front();
			}
		}
		
		template <typename T>
		void outWriteAddress(uint8_t & AWVALID, const uint8_t AWREADY,
		                     T & AWADDR) {
			if (awQueue_delayed.size()) {
				AWVALID = 1;
				AWADDR = awQueue_delayed.front().AWADDR;
				
				if (AWREADY)
					awQueue_delayed.pop_front();
					
				if (debug)
					std::cout << "outWriteAddress:"
					          << " AWADDR: " << (uint64_t) AWADDR
					          << std::endl;
			} else {
				AWVALID = 0;
				AWADDR = 0;
			}
		}
		
		template <typename T>
		void outReadAddress(uint8_t & ARVALID, const uint8_t ARREADY,
		                    T & ARADDR) {
			if (arQueue_delayed.size()) {
				ARVALID = 1;
				ARADDR = arQueue_delayed.front().ARADDR;
				
				if (ARREADY)
					arQueue_delayed.pop_front();
					
				if (debug)
					std::cout << "outReadAddress:"
					          << " ARADDR: " << (uint64_t) ARADDR
					          << std::endl;
			} else {
				ARVALID = 0;
				ARADDR = 0;
			}
		}
		
		template <typename T, typename T1>
		void outWrite(uint8_t & WVALID, const uint8_t WREADY, T & WDATA,
		              T1 & WSTRB) {
			if (wQueue_delayed.size()) {
				WVALID = 1;
				WDATA = wQueue_delayed.front().WDATA;
				WSTRB = wQueue_delayed.front().WSTRB;
				
				if (WREADY)
					wQueue_delayed.pop_front();
					
				if (debug)
					std::cout << "outWrite:"
					          << " WDATA: " << (uint64_t) WDATA
					          << " WSTRB: " << (uint64_t) WSTRB
					          << std::endl;
			} else {
				WVALID = 0;
				WDATA = 0;
				WSTRB = 0;
			}
		}
		
		template <typename T>
		void inRead(const uint8_t RVALID, uint8_t & RREADY, const T & RDATA,
		            const uint8_t RRESP) {
			if ((*random)()) {
				RREADY = 1;
			} else {
				RREADY = 0;
			}
			
			if (RVALID && RREADY) {
				rQueue.push_back({RRESP,RDATA});
				
				if (debug) {
					std::cout << "inRead:"
					          << " RRESP: " << (uint64_t) RRESP
					          << " RDATA: " << (uint64_t) RDATA
					          << std::endl;
				}
			}
		}
		
		void inWriteResp(const uint8_t BVALID, uint8_t & BREADY,
		                 const uint8_t BRESP) {
			if ((*random)()) {
				BREADY = 1;
			} else {
				BREADY = 0;
			}
			
			if (BVALID && BREADY) {
				bQueue.push_back({BRESP});
				
				if (debug) {
					std::cout << "inWriteResp: "
					          << " BRESP: " << (uint64_t) BRESP
					          << std::endl;
				}
			}
		}

};

// Base class for memory access.
// Will map a file into memory or, if no filename is given, use a temporary
// memory buffer instead.
template<size_t width>
class AXI_Memory {
	static_assert((width % 8) == 0,
	              "Memory data width needs to be a multiple of 8.");
	
	public:
		enum AXI_RESP {
			AXI_OKAY = 0, AXI_EXOKAY = 1, AXI_SLVERR = 2, AXI_DECERR = 3
		};
	
	private:
		bool debug = false;
		std::string path;
		std::unique_ptr<RandomChance> random;
		
		std::unique_ptr<mio::mmap_sink> mmap;
		std::unique_ptr<std::vector<uint8_t>> tmp;
		// Raw pointer and limit to access either backend.
		uint8_t * content = nullptr;
		size_t size = 0;
		uint8_t last_clock = 1;
		
		struct tAR { uint8_t ARID; uint8_t ARSIZE; uint8_t ARLEN; uint64_t ARADDR; };
		std::deque<tAR> arQueue;
		std::deque<tAR> arQueue_delayed;
		
		struct tAW { uint8_t AWID; uint8_t AWSIZE; uint8_t AWLEN; uint64_t AWADDR; };
		std::deque<tAW> awQueue;
		std::deque<tAW> awQueue_delayed;
		
		struct tW { std::array<unsigned char, width/8> WDATA; uint64_t WSTRB; };
		std::deque<tW> wQueue;
		std::deque<tW> wQueue_delayed;
		
		struct tR { uint8_t RID; uint8_t RRESP;
			std::array<unsigned char, width/8> RDATA; };
		std::deque<tR> rQueue;
		std::deque<tR> rQueue_delayed;
		
		struct tB { uint8_t BID; uint8_t BRESP; };
		std::deque<tB> bQueue;
		std::deque<tB> bQueue_delayed;
		
	
	public:
		AXI_Memory(argh::parser cmdl, const std::string &path, std::unique_ptr<RandomChance> random)
		: path(path), random(std::move(random)) {
			this->debug = cmdl[{ "-d", "--debug" }];
			
			if (path.length() > 0) {
				if (debug)
					std::cout << "Memory open at path '" << path << "'." << std::endl;
				mmap = std::make_unique<mio::mmap_sink>(path, 0, mio::map_entire_file);
				content = (uint8_t *) &(*mmap)[0];
				size = mmap->size();
			} else {
				if (debug)
					std::cout << "Memory opened without path. Creating temporary buffer."
					          << std::endl;
					size = 1024*1024;
					tmp = std::make_unique<std::vector<uint8_t>>(this->size);
					content = &(*tmp)[0];
			}
		}
		
	protected:
		
		template <typename T>
		void evalCommon(
				const uint8_t & ap_clk, const uint8_t & ap_rst_n,
				
				const uint8_t AWVALID, uint8_t & AWREADY, const uint64_t AWADDR,
				const uint8_t AWID, const uint8_t AWSIZE, const uint8_t AWLEN,
				
				const uint8_t WVALID, uint8_t & WREADY, const T& WDATA,
				const uint64_t WSTRB,
				
				const uint8_t ARVALID, uint8_t & ARREADY, const uint64_t ARADDR,
				const uint8_t ARID, const uint8_t ARSIZE, const uint8_t ARLEN,
				
				uint8_t & RVALID, const uint8_t RREADY, T& RDATA,
				uint8_t & RID, uint8_t & RRESP,
				
				uint8_t & BVALID, const uint8_t BREADY, uint8_t & BID,
				uint8_t & BRESP) {
			
			// Only apply and change signals on positive clock edge.
			if (!(!last_clock && ap_clk)) {
				last_clock = ap_clk;
				return; // Only apply once per cycle.
			} else {
				last_clock = ap_clk;
			}
			
			if (debug)
				std::cout << "mem eval()" << std::endl;
			
			// Incoming channels.
			inWriteAddress(AWVALID, AWREADY, AWID, AWSIZE, AWLEN, AWADDR);
			inWrite(WVALID, WREADY, WDATA, WSTRB);
			inReadAddress(ARVALID, ARREADY, ARID, ARSIZE, ARLEN, ARADDR);
			
			// Decide delays of input channels.
			if (rQueue.size() && (*random)()) {
				rQueue_delayed.emplace_back(rQueue.front());
				rQueue.pop_front();
			}
			if (bQueue.size() && (*random)()) {
				bQueue_delayed.emplace_back(bQueue.front());
				bQueue.pop_front();
			}
			
			// Apply operations from C++ queues.
			memoryOps();
			
			// Decide delays of input channels.
			if (awQueue.size() && (*random)()) {
				awQueue_delayed.emplace_back(awQueue.front());
				awQueue.pop_front();
			}
			if (wQueue.size() && (*random)()) {
				wQueue_delayed.emplace_back(wQueue.front());
				wQueue.pop_front();
			}
			if (arQueue.size() && (*random)()) {
				arQueue_delayed.emplace_back(arQueue.front());
				arQueue.pop_front();
			}
			
			// Outgoing channels below.
			outRead(RVALID, RREADY, RID, RDATA, RRESP);
			outWriteResp(BVALID, BREADY, BID, BRESP);
		}
	
	private:
		void inWriteAddress(const uint8_t AWVALID, uint8_t & AWREADY,
		                    const uint8_t AWID, const uint8_t AWSIZE, uint8_t AWLEN,
		                    const uint64_t AWADDR) {
			// TODO: Stall for realism.
			if ((*random)()) {
				AWREADY = 1;
			} else {
				AWREADY = 0;
			}
			
			if (AWVALID && AWREADY) {
				if (debug)
					std::cout << "inWriteAddress: AWID: " << (int) AWID
					          << ", AWADDR: " << AWADDR << std::endl;
				
				awQueue.push_back({AWID, AWSIZE, AWLEN, AWADDR});
			} else {
				AWREADY = 0;
			}
		}
		
		void inReadAddress(const uint8_t ARVALID, uint8_t & ARREADY,
		                   const uint8_t ARID, const uint8_t ARSIZE,
		                   const uint8_t ARLEN, const uint64_t & ARADDR) {
			// TODO: Stall for realism.
			if ((*random)()) {
				ARREADY = 1;
			} else {
				ARREADY = 0;
			}
			
			if (ARVALID && ARREADY) {
				if (debug)
					std::cout << "inReadAddress: ARID: " << (int) ARID
					          << ", ARADDR: " << ARADDR << std::endl;
				
				arQueue.push_back({ARID, ARSIZE, ARLEN, ARADDR});
			}
		}
		
		template <typename T>
		void inWrite(const uint8_t WVALID, uint8_t & WREADY, const T & WDATA,
		             const uint64_t WSTRB) {
			static_assert((width / 8) == sizeof(T),
			              "Memory data type size does not match memory data width.");
			
			if ((*random)()) {
				WREADY = 1;
			} else {
				WREADY = 0;
			}
			
			if (WVALID && WREADY) {
				if (debug)
					std::cout << "inWrite with scalar data: "
					          << std::setfill('0') << std::setw(width/4) << std::hex
					          << *(uint64_t *) &WDATA
					          << std::endl;
				
				wQueue.emplace_back();
				*((T*) &wQueue.back().WDATA) = WDATA;
			}
		}
		
		template <typename T, size_t n>
		void inWrite(const uint8_t WVALID, uint8_t & WREADY, const T(& WDATA)[n],
		             const uint64_t WSTRB) {
			static_assert((width / 8) == sizeof(T) * n,
			              "Memory data type size does not match memory data width.");
			
			if ((*random)()) {
				WREADY = 1;
			} else {
				WREADY = 0;
			}
			
			if (WVALID && WREADY) {
				wQueue.emplace_back();
				T* ptr = ((T*) &wQueue.back().WDATA);
				for (int i = 0; i < n; i++) {
					ptr[i] = WDATA[i];
				}
				
				if (debug) {
					std::cout << "inWrite with array data: ";
					for (auto b = wQueue.back().WDATA.rbegin();
					     b != wQueue.back().WDATA.rend(); b++)
						std::cout << std::setfill('0') << std::setw(2) << std::hex
						          << (unsigned int) *b;
					std::cout << std::endl;
				}
			}
		}
		
		template <typename T>
		void outRead(uint8_t & RVALID, const uint8_t RREADY, uint8_t &RID,
		             T & RDATA, uint8_t & RRESP) {
			static_assert((width / 8) == sizeof(T),
			              "Memory data type size does not match memory data width.");
			
			if (rQueue_delayed.size() > 0) {
				if (debug) {
					std::cout << "outRead with scalar data: "
					          << std::setfill('0') << std::setw(width/4) << std::hex
					          << *(uint64_t *) &rQueue_delayed.front().RDATA
					          << std::endl;
				}
				
				RVALID = 1;
				
				RDATA = *((T*) &rQueue_delayed.front().RDATA);
				
				if (RREADY) {
					rQueue_delayed.pop_front();
				}
			} else {
				RVALID = 0;
			}
		}
		
		template <typename T, size_t n>
		void outRead(uint8_t & RVALID, const uint8_t RREADY, uint8_t & RID,
		             T(& RDATA)[n], uint8_t & RRESP) {
			static_assert((width / 8) == sizeof(T) * n,
			              "Memory data type size does not match memory data width.");
			
			if (rQueue_delayed.size() > 0) {
				if (debug) {
					std::cout << "outRead with array data: ";
					for (auto b = rQueue_delayed.front().RDATA.rbegin();
					     b != rQueue_delayed.front().RDATA.rend(); b++)
						std::cout << std::setfill('0') << std::setw(2) << std::hex
						          << (unsigned int) *b;
					std::cout << std::endl;
				}
				
				RVALID = 1;
				
				T* ptr = ((T*) &rQueue_delayed.front().RDATA);
				for (int i = 0; i < n; i++) {
					RDATA[i] = ptr[i];
				}
				
				if (RREADY) {
					rQueue_delayed.pop_front();
				}
			} else {
				RVALID = 0;
			}
		}
		
		void outWriteResp(uint8_t & BVALID, const uint8_t BREADY, uint8_t & BID,
		                  uint8_t & BRESP) {
			if (bQueue_delayed.size() > 0) {
				if (debug)
					std::cout << "outWriteResp: BID: " << (int) BID
					          << ", BRESP: " << (uint64_t) BRESP << std::endl;
				
				BVALID = 1;
				
				BID = bQueue_delayed[0].BID;
				BRESP = bQueue_delayed[0].BRESP;
				
				if (BREADY) {
					bQueue_delayed.pop_front();
				}
			} else {
				BVALID = 0;
			}
		}
		
		// Actually apply enqueued operations and produce results.
		void memoryOps() {
			// TODO: Add delays.
			if (arQueue_delayed.size() > 0) {
				auto id = arQueue_delayed.front().ARID;
				auto addr = arQueue_delayed.front().ARADDR;
				if (size > (addr + (width/8))) {
					if (debug)
						std::cout << "Apply read from " << addr << std::endl;
					rQueue.emplace_back();
					rQueue.back().RID = id;
					rQueue.back().RRESP = AXI_OKAY;
					memcpy(&rQueue.back().RDATA[0], &content[addr], width/8);
					
					// More beats left for this transaction?
					if (arQueue_delayed.front().ARLEN > 0) {
							arQueue_delayed.front().ARADDR += (width/8);
							arQueue_delayed.front().ARLEN -= 1;
					} else {
						arQueue_delayed.pop_front();
					}
				} else {
					std::cout << "Out of bounds read at " << addr << std::endl;
					
					rQueue.emplace_back();
					rQueue.back().RID = id;
					rQueue.back().RRESP = AXI_SLVERR;
				}
			}
			
			if (awQueue_delayed.size() > 0 && wQueue_delayed.size() > 0) {
				auto id = awQueue_delayed.front().AWID;
				auto addr = awQueue_delayed.front().AWADDR;
				if (size > (addr + (width/8))) {
					if (debug)
						std::cout << "Apply write to " << addr << std::endl;
					
					memcpy(&content[addr], &wQueue_delayed.front().WDATA[0], width/8);
					bQueue.emplace_back();
					bQueue.back().BID = id;
					bQueue.back().BRESP = AXI_OKAY;
					
					wQueue_delayed.pop_front();
					// More beats left for this transaction?
					if (awQueue_delayed.front().AWLEN > 0) {
							awQueue_delayed.front().AWADDR += (width/8);
							awQueue_delayed.front().AWLEN -= 1;
					} else {
						awQueue_delayed.pop_front();
					}
				} else {
					std::cout << "Out of bounds write at " << addr << std::endl;
					bQueue.emplace_back();
					bQueue.back().BRESP = AXI_SLVERR;
					
					awQueue_delayed.pop_front();
					wQueue_delayed.pop_front();
				}
			}
		}
};

// NOTE:
// The combination AXI and Verilator requires us to access simulated system
// memory interfaces by different C++ class member names.
// Examples: axi_m_global_AWADDR, axi_m_global_AWVALID, etc... for a memory
// named "global".
// The following example class is a minimal adapter to connect to one such set
// of ports. All interesting interaction is handled in the AXI_Memory base
// class.

// COPY MEMORY BELOW.
template<size_t width>
class Minsert_memory_name_here : AXI_Memory<width> {
	public:
		Minsert_memory_name_here<width>(argh::parser cmdl, const std::string &path, std::unique_ptr<RandomChance> random)
			: AXI_Memory<width>(cmdl,path, std::move(random)) {}
		
		void eval(Vinsert_module_name_here &sys) {
			this->evalCommon(
				sys.ap_clk, sys.ap_rst_n,
				sys.m_axi_insert_memory_name_here_AWVALID,
				sys.m_axi_insert_memory_name_here_AWREADY,
				sys.m_axi_insert_memory_name_here_AWADDR,
				sys.m_axi_insert_memory_name_here_AWID,
				sys.m_axi_insert_memory_name_here_AWSIZE,
				sys.m_axi_insert_memory_name_here_AWLEN,
				sys.m_axi_insert_memory_name_here_WVALID,
				sys.m_axi_insert_memory_name_here_WREADY,
				sys.m_axi_insert_memory_name_here_WDATA,
				sys.m_axi_insert_memory_name_here_WSTRB,
				sys.m_axi_insert_memory_name_here_ARVALID,
				sys.m_axi_insert_memory_name_here_ARREADY,
				sys.m_axi_insert_memory_name_here_ARADDR,
				sys.m_axi_insert_memory_name_here_ARID,
				sys.m_axi_insert_memory_name_here_ARSIZE,
				sys.m_axi_insert_memory_name_here_ARLEN,
				sys.m_axi_insert_memory_name_here_RVALID,
				sys.m_axi_insert_memory_name_here_RREADY,
				sys.m_axi_insert_memory_name_here_RDATA,
				sys.m_axi_insert_memory_name_here_RID,
				sys.m_axi_insert_memory_name_here_RRESP,
				sys.m_axi_insert_memory_name_here_BVALID,
				sys.m_axi_insert_memory_name_here_BREADY,
				sys.m_axi_insert_memory_name_here_BID,
				sys.m_axi_insert_memory_name_here_BRESP);
		}
};
// COPY MEMORY ABOVE.


int main(int argc, char** argv) {
	argh::parser cmdl(argc, argv);
	bool debug = cmdl[{ "-d", "--debug" }];
	
	
	vluint64_t max_sim_steps = 100000;
	cmdl({ "-m", "--max-sim-steps"}) >> max_sim_steps;
	
	vluint64_t random_divisor = 0;
	cmdl({ "-r", "--random-divisor"}) >> random_divisor;
	
	vluint64_t random_seed = 1988;
	cmdl({ "-s", "--random-seed"}) >> random_seed;
	
	auto random = RandomGen(random_seed);
	
	std::unique_ptr<VerilatedVcdC> trace;
	std::string traceFileName = cmdl({ "-t", "--trace-vcd-file"}).str();
	if (traceFileName.length() > 0) {
		Verilated::traceEverOn(true);
		trace = std::make_unique<VerilatedVcdC>();
		std::cout << "Writing trace to " << traceFileName << std::endl;
	}
	
	Verilated::commandArgs(argc, argv);
	
	Vinsert_module_name_here insert_module_name_here;
	
	// Just for testing, will loose meaning after template instantiation
	int insert_memory_width_here = 64;
	
	// COPY MEMORY BELOW.
	Minsert_memory_name_here<insert_memory_width_here>
		mem_insert_memory_name_here(
			cmdl, cmdl({ "--insert_memory_name_here" }).str(),
			std::make_unique<RandomChance>(random_divisor, random() * 43));
	// COPY MEMORY ABOVE.
	
	VITIS_CTRL ctrl( cmdl,
		std::make_unique<RandomChance>(random_divisor, random() * 43));
	ctrl.start({0,0,64,0});
	
	if (trace) {
		// TODO: Set depth via command line arg.
		insert_module_name_here.trace(trace.get(), 0);
		trace->open(traceFileName.c_str());
	}
	
	insert_module_name_here.ap_clk = 0;
	
	insert_module_name_here.ap_rst_n = 1;
	for (main_time = 0; main_time < 8; main_time++) {
		insert_module_name_here.ap_clk =
			!insert_module_name_here.ap_clk;
		insert_module_name_here.eval();
	}
	insert_module_name_here.ap_rst_n = 0;
	
	while (!Verilated::gotFinish() && !ctrl.isDone()
	       && main_time <= max_sim_steps) {
		main_time++;
		
		if (debug) {
			std::cout << "# " << main_time << std::endl;
		}
		
		insert_module_name_here.ap_clk =
			!insert_module_name_here.ap_clk;
		
		insert_module_name_here.eval();
		// COPY MEMORY BELOW.
		mem_insert_memory_name_here.eval(insert_module_name_here);
		// COPY MEMORY ABOVE.
		ctrl.eval(insert_module_name_here);
		insert_module_name_here.eval();
		
		if (trace) {
			trace->dump(main_time);
		}
	}
	
	if (trace) {
		trace->close();
	}
	
	// TODO: Should this not be called in the destructor generated by Verilator?
	// Experiments have shown issues with trace flushing when this is not called
	// explicitly, so maybe inspect and bug-report the generated code.
	insert_module_name_here.final();
	
	exit(0);
}

