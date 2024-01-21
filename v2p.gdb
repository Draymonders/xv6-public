# -*- mode: gdb-script; -*-

define v2p
	set $va = $arg0
	set $kernal_base = 0x80000000
	set $pgdir = $cr3

	set $pdx = (uint)($va >> 22) & 0x3ff
	set $ptx = (uint)($va >> 12) & 0x3ff
	set $offset = (uint)($va) & 0xfff
	printf "Prepare: va=0x%08x pdx=0x%08x ptx=0x%08x offset=0x%08x\n", $va, $pdx, $ptx, $offset 
	
	set $pde = $pgdir + ($pdx << 2) + $kernal_base
	set $ppn1= *(pte_t *)($pde) & ~0xfff
	printf "Step1: $cr3=0x%08x pdx=0x%08x pde=0x%08x ppn1=0x%08x\n", $pgdir, $pdx, $pde, $ppn1

	set $pte = $ppn1 + ($ptx << 2) + $kernal_base
	set $ppn2 = *(pte_t *)($pte) & ~0xfff
	printf "Step2: ppn1=0x%08x ptx=0x%08x pte=0x%08x ppn2=0x%08x\n", $ppn1, $ptx, $pte, $addr2

	set $pa = $ppn2 | $offset
	printf "Step3: ppn2=0x%08x offset=0x%08x\n", $ppn2, $offset
	printf "End: va=0x%08x pa=0x%08x\n", $va, $pa
end
