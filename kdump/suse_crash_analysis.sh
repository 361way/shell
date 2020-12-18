mkdir -p /tmp/kdump
crash $*   <<EOF  >/tmp/kdump/kdumpoutput.txt 2>&1
log >/tmp/kdump/log.txt
sys >/tmp/kdump/sys.txt
bt >/tmp/kdump/bt.tx
foreach bt >/tmp/kdump/all-bt.txt
foreach files>/tmp/kdump/all-files.txt
ps >/tmp/kdump/ps.txt
swap>/tmp/kdump/swap.txt
runq >/tmp/kdump/runq.txt
mount >/tmp/kdump/mount.txt
net >/tmp/kdump/net.txt 
dev >/tmp/kdump/dev.txt
dev -i >/tmp/kdump/dev-i.txt
dev -p >/tmp/kdump/dev-p.txt
files >/tmp/kdump/files.txt
irq >/tmp/kdump/irq.txt
kmem -f >/tmp/kdump/pmemory.txt
kmem -i >/tmp/kdump/memory.txt
mach >/tmp/kdump/mach.txt
mod >/tmp/kdump/modules.txt
net -s >/tmp/kdump/net-s.txt
ps -t >/tmp/kdump/ps-t.txt
ps -c >/tmp/kdump/ps-c.txt
sig >/tmp/kdump/sig.txt
set >/tmp/kdump/set.txt
task >/tmp/kdump/task.txt
foreach task >/tmp/kdump/all-task.txt
sym -l >/tmp/kdump/sys-l.txt
sym -M >/tmp/kdump/sys-M.txt
quit
EO
