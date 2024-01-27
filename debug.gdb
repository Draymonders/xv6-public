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
	printf "Step2: ppn1=0x%08x ptx=0x%08x pte=0x%08x ppn2=0x%08x\n", $ppn1, $ptx, $pte, $ppn2

	set $pa = $ppn2 | $offset
	printf "Step3: ppn2=0x%08x offset=0x%08x\n", $ppn2, $offset
	printf "End: va=0x%08x pa=0x%08x\n", $va, $pa
end

define idx
	set $va = $arg0
	
	set $pdx = (uint)($va >> 22) & 0x3ff
	set $ptx = (uint)($va >> 12) & 0x3ff
	set $offset = (uint)($va) & 0xfff
	printf "va=0x%08x pdx=0x%08x ptx=0x%08x offset=0x%08x\n", $va, $pdx, $ptx, $offset 
end

define ppn
	set $pte = $arg0
	
	set $PPN = $pte & ~0xfff
	set $flags = $pte & 0xfff

	printf "PPN=0x%08x FLAGS=0x%08x\n", $PPN, $flags 
end

define freelist
	set $lst = kmem->freelist

	set $i = 0
	set $cur = $lst
	while $cur != 0 
		set $i = $i+1
		set $node = (struct run*)$cur
		if ($i < 10)
			printf "node-%d: 0x%08x\n", $i, $node
		end
		set $cur = $node->next
	end
	set $sz = $i * 1024 * 1024
	printf "list_len: %d mem_size: %.2fM\n", $i, (float)($sz / 1024 / 1024)
end


define proclist 
	set $i = 0
	
	while $i < 64 
		set $pid = ptable.proc[$i]->pid
		set $pname = ptable.proc[$i]->name
		set $state = ptable.proc[$i]->state
		if $pid > 0
			set $proc_parent = ptable.proc[$i]->parent
			set $proc_ppid = 0
			if $proc_parent != 0
				set $proc_ppid = ptable.proc[$i]->parent->pid
			end
			printf "proc[%d]: pid=%d name='%s' state=%d parent_pid=%d\n", $i, $pid, $pname, $state, $proc_ppid

		end
		set $i = $i + 1
	end
end
