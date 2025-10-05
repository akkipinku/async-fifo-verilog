Module Explanations :

1. fifo_mem.v (Top-level FIFO)

This is the main FIFO memory module.

It instantiates the read, write, and sync modules.

Stores data in a memory array (fifo_mem) of size fifo_depth.

Handles write operation on w_clk and read operation on r_clk.

Includes data width adjustment logic:

If datain_width < dataout_width: Packs multiple inputs together before output.

If datain_width > dataout_width: Splits input data into smaller chunks across multiple reads.


2. read.v (Read Pointer & Empty Flag Controller)

Maintains the read pointer (readaddrptr) in binary and converts it into Gray code (readaddrptrgrey).

Generates the empty flag by comparing the synchronized write pointer (writeaddrptrgreysync) with the current read pointer.

Supports variable data widths:

If dataout_width >= datain_width: Advances pointer faster to fetch multiple words.

If dataout_width < datain_width: Uses a counter to output slices of the stored data.


3. write.v (Write Pointer & Full Flag Controller)

Maintains the write pointer (writeaddrptr) in binary and converts it into Gray code (writeaddrptrgrey).

Generates the full flag by comparing the Gray-coded write pointer with the synchronized read pointer.

On every valid write (wen && !full), increments the pointer and writes data into FIFO memory.


4. sync.v (Cross-Domain Synchronizer)

Synchronizes Gray-coded pointers between the two different clock domains (w_clk and r_clk).

Uses two flip-flop stages for each pointer to avoid metastability.

Ensures:

The write pointer is safely available in the read clock domain.

The read pointer is safely available in the write clock domain.
