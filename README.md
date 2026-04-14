# CryptoCore 16 - Cryptographic Coprocessor

CryptoCore 16 is a 16-bit cryptographic coprocessor that accelerates encryption operations by implementing them in hardware rather than software. It sits alongside a main CPU and handles computationally intensive cryptographic primitives such as:

- **Arithmetic operations** (ADD, SUB)
- **Bitwise logic** (AND, OR, XOR, NOT)
- **Bit manipulation** (rotations and shifts)
- **Non-linear substitution** (LUT-based transformations)

### Why Hardware Acceleration?

Cryptographic algorithms require executing the same operations hundreds of thousands of times per second. Implementing these in dedicated hardware:

- Executes operations in a single clock cycle
- Reduces CPU load
- Increases throughput significantly
- Provides constant-time execution (security benefit)

---

## Architecture

### Block Diagram

```
                    ┌─────────────────────────────────────────┐
                    │                                         │
    Clock ─────────►│                                         │
    Reset ─────────►│                                         │
    CTRL[3:0] ─────►│          Input Register                 │
    Ra[3:0] ───────►│          (Pipeline Stage)               │
    Rb[3:0] ───────►│                                         │
    Rd[3:0] ───────►│                                         │
                    └──────────────┬──────────────────────────┘
                                   │
                                   ▼
                    ┌──────────────────────────────┐
                    │                              │
    Clock ─────────►│   16x16 Register File        │
    Reset ─────────►│   (Synchronous Read/Write)   │
    Ra[3:0] ───────►│                              │
    Rb[3:0] ───────►│   Ra ──► ABUS[15:0]         │
    Rd[3:0] ───────►│   Rb ──► BBUS[15:0]         │
                    │   Rd ◄── RESULT[15:0]       │
                    │                              │
                    └────────┬──────────┬──────────┘
                             │          │
                             │          │
                             ▼          ▼
                    ┌────────────────────────────────────────┐
                    │                                        │
                    │   Combinational Logic Block            │
                    │                                        │
                    │  ┌──────────────────────────────────┐ │
                    │  │         ALU Unit                 │ │
    ABUS[15:0] ────────►│  ADD, SUB, AND, OR, XOR,       │ │
    BBUS[15:0] ────────►│  NOT, MOV, NOP                 │ │
    CTRL[3:0] ─────────►├─────────────┬─ alu_out1[15:0] │ │
                    │  └─────────────┼──────────────────┘ │
                    │                │                     │
                    │  ┌─────────────┼──────────────────┐ │
                    │  │         Shifter Unit          │ │
    BBUS[15:0] ────────►│  ROR8, ROR4, SLL8           │ │
    CTRL[3:0] ─────────►├─────────────┬─ sft_out2[15:0] │ │
                    │  └─────────────┼──────────────────┘ │
                    │                │                     │
                    │  ┌─────────────┼──────────────────┐ │
                    │  │    Non-Linear Lookup Unit     │ │
    ABUS[15:0] ────────►│  S_Box1 + S_Box2             │ │
                    │  │  (Substitution Tables)        │ │
                    │  └─────────────┬─lut_out3[15:0] │ │
                    │                │                     │
                    │       ┌────────▼─────────┐          │
                    │       │   Control MUX    │          │
                    │       │   (CTRL-based    │          │
                    │       │    selection)    │          │
                    │       └────────┬─────────┘          │
                    │                │                     │
                    └────────────────┼─────────────────────┘
                                     │
                                     ▼
                              RESULT[15:0]
                                     │
                                     │ (Write Enable controlled by NOP)
                                     ▼
                           Register File[Rd] ◄─ Write-back
```

---

## Data Flow

### Complete Data Flow Path (Step-by-Step)

Let's trace an example instruction: **ADD R5, R4 → R12**

**Instruction Encoding:**

```
CTRL = 0000 (ADD operation)
Ra   = 0101 (Register 5)
Rb   = 0100 (Register 4)
Rd   = 1100 (Register 12)
```

### Clock Cycle Breakdown

#### **Cycle N (Input Capture)**

1. **Input signals arrive** at the processor pins
2. **Input register latches** on rising clock edge:
   - `CTRL` → stored internally
   - `Ra`, `Rb`, `Rd` → stored internally
   - This creates a pipeline stage, stabilizing inputs during operation

#### **Cycle N (Combinational Phase - same cycle)**

3. **Register File Read** (synchronous read on same clock edge):

   ```
   Ra = 0101 → Register[5] → ABUS = 0xF407
   Rb = 0100 → Register[4] → BBUS = 0x1186
   ```

4. **All three functional units operate in parallel** (combinational logic):

   **a) ALU receives ABUS and BBUS:**
   - CTRL = 0000 → Selects ADD operation
   - Calculation: `0xF407 + 0x1186 = 0x058D`
   - Output: `alu_out1 = 0x058D`

   **b) Shifter receives BBUS:**
   - CTRL = 0000 → No shift operation (inactive)
   - Output: `sft_out2 = (don't care)`

   **c) Lookup Unit receives ABUS:**
   - CTRL = 0000 → No LUT operation (inactive)
   - Output: `lut_out3 = (don't care)`

5. **Control MUX selects correct output:**

   ```vhdl
   -- Control Logic
   if CTRL[3] = '0' then
       RESULT <= tmp_out1 (ALU output)
   elsif CTRL[1:0] = "11" then
       RESULT <= tmp_out3 (LUT output)
   else
       RESULT <= tmp_out2 (Shifter output)
   end if
   ```

   - Since CTRL[3] = '0', MUX selects `alu_out1`
   - `RESULT = 0x058D`

6. **Write Enable Logic:**

   ```vhdl
   if CTRL = "0111" then  -- NOP instruction
       Write_Enable <= '0'
   else
       Write_Enable <= '1'
   end if
   ```

   - CTRL ≠ 0111, so `Write_Enable = '1'`

#### **Cycle N+1 (Write-back)**

7. **Register File Write** (on next rising clock edge):

   ```
   Register[Rd] ← RESULT
   Register[12] ← 0x058D
   ```

   - Write only occurs if `Write_Enable = '1'`
   - Write is synchronous (happens on clock edge)

### Data Path Summary

```
Input Pins → Input Register → Register File (Read) → ABUS/BBUS
                                                         ↓
                                              Combinational Block
                                             (ALU/Shifter/LUT)
                                                         ↓
                                                Control MUX
                                                         ↓
                                                     RESULT
                                                         ↓
                                              Register File (Write)
```

---

## Component Descriptions

### 1. Input Register (Pipeline Stage)

**File:** `Crypto_core16.vhd` (internal process)

**Purpose:** Stabilizes control signals and register addresses

**Why it exists:**

- Prevents timing issues by registering inputs
- Creates a stable control environment during computation
- Implements a simple pipeline stage

---

### 2. Register File

**File:** `register.vhd`

**Specifications:**

- **Size:** 16 registers × 16 bits = 256 bits total
- **Addressing:** 4-bit addresses (Ra, Rb, Rd)
- **Read Ports:** 2 (Ra → ABUS, Rb → BBUS)
- **Write Ports:** 1 (RESULT → Rd)
- **Operation:** Synchronous read and write

**Pre-initialized Dummy Values:**

```
R0  = 0x0001    R8  = 0x6808
R1  = 0xC505    R9  = 0xBAA0
R2  = 0x3C07    R10 = 0xC902
R3  = 0x4D05    R11 = 0x100B
R4  = 0x1186    R12 = 0xC000
R5  = 0xF407    R13 = 0xC902
R6  = 0x1086    R14 = 0x100B
R7  = 0x4706    R15 = 0xB000
```

---

### 3. Arithmetic Logic Unit (ALU)

**File:** `ALU.vhd`

**Operations Supported:**

- ADD (0000)
- SUB (0001)
- AND (0010)
- OR (0011)
- XOR (0100)
- NOT (0101)
- MOV (0110)
- NOP (0111)

**Characteristics:**

- **Purely combinational** - no clock required
- Output updates immediately when inputs change
- Uses `numeric_std` for arithmetic (cleaner than instantiating adders)
- All 16-bit operations

---

### 4. Shifter Unit

**File:** `shifter.vhd`

**Operations:**

- **ROR8 (1000):** Rotate right 8 bits (swap bytes)
- **ROR4 (1001):** Rotate right 4 bits (rotate by nibble)
- **SLL8 (1010):** Shift left 8 bits (logical shift, zero-fill)

**Operation Examples:**

**ROR8 (Byte Swap):**

```
Before: [1011 1010] [1010 0000]
After:  [1010 0000] [1011 1010]
```

**ROR4 (Nibble Rotate):**

```
Before: [1011 1010 1010] [0000]
After:  [0000] [1011 1010 1010]
```

**SLL8 (Shift Left with Zero Fill):**

```
Before: [1011 1010] [1010 0000]
         ^^^^^^^^    ^^^^^^^^
          lost        kept
After:  [1010 0000] [0000 0000]
```

**Key Difference:**

- **Rotate:** Bits wrap around, nothing is lost
- **Shift:** Bits fall off the edge, zeros fill in

---

### 5. Non-Linear Lookup Unit (S-Box)

**File:** `LUT.vhd`

**Purpose:**
Provides non-linear substitution - a critical component of secure encryption. Linear operations (XOR, ADD) can be reversed algebraically. Non-linear substitution breaks this pattern.

**Data Flow:**

```
ABUS[15:0] input
    │
    ├─► [15:8] ──────────────────────┐
    │                                 │
    └─► [7:0] ───┬──► [7:4] ──► S_Box1 ──► 4-bit output ──┐
                 │                                         │
                 └──► [3:0] ──► S_Box2 ──► 4-bit output ──┼──► [7:0] combined
                                                           │
                 ┌─────────────────────────────────────────┘
                 │
                 ▼
         ABUS[15:8] & [S_Box1_out & S_Box2_out]
                 │
                 ▼
          LUTOUT[15:0]
```

**Why Non-Linear?**

- Makes the encryption mathematically irreversible without the key
- Prevents attacks based on linear algebra
- These specific S-Boxes are simplified versions for demonstration

---

### 6. Combinational Logic Block

**File:** `combinational_logic_block.vhd`

**Purpose:**
Integrates ALU, Shifter, and LUT with output multiplexing

**Control unit MUX Selection Logic:**

```
CTRL[3] = 0  →  ALU output     (operations 0000-0111)
CTRL[3] = 1:
    CTRL[1:0] = 11  →  LUT output     (operation 1011)
    CTRL[1:0] ≠ 11  →  Shifter output (operations 1000, 1001, 1010)
```

---

### 7. Top-Level Coprocessor

**File:** `crypto_core16.vhd`

**Purpose:**
Connects register file, combinational logic, and control logic

**Key Features:**

- Input pipeline register
- Write enable control (disables writes for NOP)
- Complete data path integration

---

## Instruction Set

### Complete Instruction Set Architecture (ISA)

| CTRL (Opcode) | Mnemonic | Operation             | Description                        |
| ------------- | -------- | --------------------- | ---------------------------------- |
| `0000`        | ADD      | ABUS + BBUS → RESULT  | Unsigned addition                  |
| `0001`        | SUB      | ABUS - BBUS → RESULT  | Unsigned subtraction               |
| `0010`        | AND      | ABUS & BBUS → RESULT  | Bitwise AND                        |
| `0011`        | OR       | ABUS \| BBUS → RESULT | Bitwise OR                         |
| `0100`        | XOR      | ABUS ^ BBUS → RESULT  | Bitwise XOR (encryption primitive) |
| `0101`        | NOT      | ~ABUS → RESULT        | Bitwise NOT (complement)           |
| `0110`        | MOV      | ABUS → RESULT         | Move/Copy register                 |
| `0111`        | NOP      | -                     | No operation (write disabled)      |
| `1000`        | ROR8     | Rotate right 8 bits   | Swap bytes                         |
| `1001`        | ROR4     | Rotate right 4 bits   | Rotate by nibble                   |
| `1010`        | SLL8     | Shift left 8 bits     | Logical shift, zero-fill           |
| `1011`        | LUT      | S-Box substitution    | Non-linear lookup                  |

### Instruction Format

```
┌──────────┬──────────┬──────────┬──────────┐
│  CTRL    │    Ra    │    Rb    │    Rd    │
│ [3:0]    │  [3:0]   │  [3:0]   │  [3:0]   │
│ Opcode   │  Src A   │  Src B   │  Dest    │
└──────────┴──────────┴──────────┴──────────┘
```

### Example Programs

#### Example 1: Encrypt with XOR

```assembly
XOR R1, R8, R7    ; CTRL=0100, Ra=0001, Rb=1000, Rd=0111
; R7 = R1 XOR R8
; 0xC505 XOR 0x6808 = 0xAD0D → R7
```

#### Example 2: S-Box Substitution

```assembly
LUT R9, R2        ; CTRL=1011, Ra=1001, Rb=xxxx, Rd=0010
; R2[15:8] = R9[15:8] (unchanged)
; R2[7:0]  = S_Box1(R9[7:4]) & S_Box2(R9[3:0])
```

#### Example 3: Rotate and Add

```assembly
ROR4 R12, R0      ; CTRL=1001, Ra=xxxx, Rb=1100, Rd=0000
ADD  R0, R7, R10  ; CTRL=0000, Ra=0000, Rb=0111, Rd=1010
; First: Rotate R12 right 4 bits → R0
; Then: Add R0 + R7 → R10
```

---

## S-Box Lookup Tables

### S_Box1 (Upper Nibble Substitution)

| Input | Output | Input | Output |
| ----- | ------ | ----- | ------ |
| 0000  | 0001   | 1000  | 1110   |
| 0001  | 1011   | 1001  | 1000   |
| 0010  | 1001   | 1010  | 0111   |
| 0011  | 1100   | 1011  | 0100   |
| 0100  | 1101   | 1100  | 1010   |
| 0101  | 0110   | 1101  | 0010   |
| 0110  | 1111   | 1110  | 0101   |
| 0111  | 0011   | 1111  | 0000   |

### S_Box2 (Lower Nibble Substitution)

| Input | Output | Input | Output |
| ----- | ------ | ----- | ------ |
| 0000  | 1111   | 1000  | 1001   |
| 0001  | 0000   | 1001  | 0010   |
| 0010  | 1101   | 1010  | 1100   |
| 0011  | 0111   | 1011  | 0001   |
| 0100  | 1011   | 1100  | 0011   |
| 0101  | 1110   | 1101  | 0100   |
| 0110  | 0101   | 1110  | 1000   |
| 0111  | 1010   | 1111  | 0110   |

### S-Box Operation Example

**Input:** `ABUS = 0xAB5C` (want to transform lower byte 0x5C)

**Step 1: Split into nibbles**

```
0x5C = [0101] [1100]
         ^^^^   ^^^^
       upper  lower
         5      C
```

**Step 2: Look up substitutions**

- S_Box1[0x5] = 0x6
- S_Box2[0xC] = 0x3

**Step 3: Combine**

```
Result = 0x6 & 0x3 = 0x63
```

**Final Output:**

```
LUTOUT = ABUS[15:8] & 0x63 = 0xAB63
```

---

## Register File

### Initial Values (Pre-loaded for Testing)

```
Address | Value  | Hex View
--------|--------|-------------
R0      | 0x0001 | 0000 0000 0000 0001
R1      | 0xC505 | 1100 0101 0000 0101
R2      | 0x3C07 | 0011 1100 0000 0111
R3      | 0x4D05 | 0100 1101 0000 0101
R4      | 0x1186 | 0001 0001 1000 0110
R5      | 0xF407 | 1111 0100 0000 0111
R6      | 0x1086 | 0001 0000 1000 0110
R7      | 0x4706 | 0100 0111 0000 0110
R8      | 0x6808 | 0110 1000 0000 1000
R9      | 0xBAA0 | 1011 1010 1010 0000
R10     | 0xC902 | 1100 1001 0000 0010
R11     | 0x100B | 0001 0000 0000 1011
R12     | 0xC000 | 1100 0000 0000 0000
R13     | 0xC902 | 1100 1001 0000 0010
R14     | 0x100B | 0001 0000 0000 1011
R15     | 0xB000 | 1011 0000 0000 0000
```

---
