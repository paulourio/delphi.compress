unit UthrExecutar;

interface

uses
  Classes, Windows, SysUtils, ShellApi, UfrmPrincipal;

type
  TThrExecutar = class(TThread)
  private
    FArquivo: String;
    FForm: TfrmPrincipal;
    FParam: String;
    FStatus: String;
    procedure SetArquivo(const Value: String);
    procedure SetParam(const Value: String);
  protected
    procedure Execute; override;
  public
    constructor Create(const AForm: TfrmPrincipal);

    property Arquivo: String read FArquivo write SetArquivo;
    property Parametros: String read FParam write SetParam;
    property Status: String read FStatus;
  end;

implementation

{ ThrExecutar }

function GetCpuUsage(pId: Cardinal): Single;
const
  cWaitTime = 750;
var
  mCreationTime, mExitTime, mKernelTime, mUserTime: _FILETIME;
  TotalTime1, TotalTime2: int64;
begin
  GetProcessTimes(pId, mCreationTime, mExitTime, mKernelTime, mUserTime);
  TotalTime1 := int64(mKernelTime.dwLowDateTime or
    (mKernelTime.dwHighDateTime shr 32)) + int64(mUserTime.dwLowDateTime or
    (mUserTime.dwHighDateTime shr 32));
  Sleep(cWaitTime);
  GetProcessTimes(pId, mCreationTime, mExitTime, mKernelTime, mUserTime);
  TotalTime2 := int64(mKernelTime.dwLowDateTime or
    (mKernelTime.dwHighDateTime shr 32)) + int64(mUserTime.dwLowDateTime or
    (mUserTime.dwHighDateTime shr 32));
  Result := ((TotalTime2 - TotalTime1) / cWaitTime) / 100;
  //CloseHandle(h);
end;

constructor TThrExecutar.Create(const AForm: TfrmPrincipal);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FForm := AForm;
end;

procedure TThrExecutar.Execute;
var
  SEInfo: TShellExecuteInfo;
  ExitCode: DWORD;
  Uso: Single;
begin
  FillChar(SEInfo, SizeOf(SEInfo), 0);
  SEInfo.cbSize := SizeOf(TShellExecuteInfo);
  with SEInfo do
  begin
    fMask := SEE_MASK_NOCLOSEPROCESS;
    Wnd := 0;
    lpFile := PWideChar(FArquivo);
    lpParameters := PWideChar(FParam);
    nShow := SW_HIDE;
  end;

  if ShellExecuteEx(@SEInfo) then
    repeat
      SleepEx(1, false);
      Uso := GetCpuUsage(SEInfo.hProcess);
      if Uso > 100 then
        Uso := 100;
      FStatus := Format('%3.2f%%', [Uso]);
      Synchronize(
        procedure
        begin
          FForm.lblStatusDetalhe.Caption := 'Uso de CPU: ' + FStatus;
        end
      );
      GetExitCodeProcess(SEInfo.hProcess, ExitCode);
    until (ExitCode <> STILL_ACTIVE);
    SendMessage(FForm.Handle, WM_FINALIZADO, ExitCode, 0);
end;

procedure TThrExecutar.SetArquivo(const Value: String);
begin
  FArquivo := Value;
end;

procedure TThrExecutar.SetParam(const Value: String);
begin
  FParam := Value;
end;

end.
