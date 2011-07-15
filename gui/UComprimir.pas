unit UComprimir;

interface

uses Windows, Forms, SysUtils, Classes, Dialogs, UfrmPrincipal, UthrExecutar;

function GerarArquivoTemporario: string;
procedure Comprimir(AForm: TfrmPrincipal);
function TamanhoArquivo(const AString: string): LongWord;

var
  Exec: TThrExecutar;
  
implementation    

function TamanhoArquivo(const AString: string): LongWord;
var
   FileHandle: THandle;
   FileSize: LongWord;
begin
   FileHandle := CreateFile(PWideChar(AString),
                           GENERIC_READ,
                           0, {exclusive}
                           nil, {security}
                           OPEN_EXISTING,
                           FILE_ATTRIBUTE_NORMAL,
                           0);
   FileSize   := GetFileSize(FileHandle, nil);
   Result     := FileSize;
   CloseHandle(FileHandle);
end;

function GerarArquivoTemporario: string;
var
  wtempDir: Array[0..MAX_PATH] of WideChar;
  wtempFile: Array[0..50] of WideChar;
begin
  GetTempPath(MAX_PATH, @wtempDir);
  GetTempFileName(@wtempDir, PWideChar('upx'), 0, @wtempFile);
  Result := StrPas(wtempFile);
  while not DeleteFile(Result) do ;
  Result := Result + '.exe';
end;

procedure ExtrairUPX(Arquivo: String);
var
  res: TResourceStream;
begin
  res := TResourceStream.Create(HInstance, 'upxexe', RT_RCDATA);
  try
    res.SaveToFile(Arquivo);
    //ShowMessage(Arquivo);
  finally
    res.Free;
  end;
end;

procedure RemoverUPX(Arquivo: String);
begin
  DeleteFile(Arquivo);
end;

function MontarOpcoes(Form: TfrmPrincipal): String;
var
  Opcoes: TStringList;
  S: string;
begin
  Result := EmptyStr;


  if Form.bmMetodo.ItemIndex = 0 then
    Exit;
  if Form.bmMetodo.ItemIndex = 1 then
  begin
    Result := '--best';
    Exit;
  end;
  if Form.bmMetodo.ItemIndex = 2 then
  begin
    Result := '--lzma --best';
    Exit;
  end;
  if Form.bmMetodo.ItemIndex = 3 then
  begin
    Result := '--brute';
    Exit;
  end;
  if Form.bmMetodo.ItemIndex = 4 then
  begin
    Result := '--ultra-brute';
    Exit;
  end;

  Opcoes := TStringList.Create;
  with Form do
  try
    case cbCompressExport.ItemIndex of
      0: Opcoes.Append('--compress-exports=0');
      1: ; // Nada
      2: Opcoes.Append('--compress-exports=1');
    end;
    case cbCompressIcons.ItemIndex of
      0: Opcoes.Append('--compress-icons=0');
      1: Opcoes.Append('--compress-icons=1');
      2: Opcoes.Append('--compress-icons=2');
      3: Opcoes.Append('--compress-icons=3');
    end;
    case cbCompressIcons.ItemIndex of
      0: Opcoes.Append('--compress-icons=0');
      1: Opcoes.Append('--compress-icons=1');
      2: Opcoes.Append('--compress-icons=2');
      3: Opcoes.Append('--compress-icons=3');
    end;
    case cbResources.ItemIndex of
      0: Opcoes.Append('--compress-resources=0');
      1: ; // Nada
    end;
    case cbStripRelocs.ItemIndex of
      0: Opcoes.Append('--strip-relocs=0');
      1: Opcoes.Append('--strip-relocs=1');
    end;
    case cbOverlay.ItemIndex of
      0: Opcoes.Append('--overlay=copy');
      1: Opcoes.Append('--overlay=strip');
      2: Opcoes.Append('--overlay=skip');
    end;
    with tbrNivel do
      if Position < Max then
        Opcoes.Add('-' + IntToStr(Position))
      else
        Opcoes.Add('--best');
    case cbMetodo.ItemIndex of
      0: ; // Padrão
      1: Opcoes.Append('--lzma');
      2: Opcoes.Append('--brute');
      3: Opcoes.Append('--ultra-brute');
    end;
    if cbAllMethods.Checked then
      Opcoes.Add('--all-methods');
    if cbAllFilters.Checked then
      Opcoes.Add('--all-filters');
    if cbForced.Checked then
      Opcoes.Add('--force');
    for S in Opcoes do
      Result := Result + S + #32;
    Result := Trim(Result);
  finally
    FreeAndNil(Opcoes);
  end;
end;

procedure Comprimir(AForm: TfrmPrincipal);
var
  UPX, Parametros, Saida, Entrada: String;
begin
  UPX := GerarArquivoTemporario;
  Entrada := AForm.btnEscolherArquivo.Caption;
  Saida := GerarArquivoTemporario;
  ExtrairUPX(UPX);
  try
    AForm.Status('Criando configurações...');
    Parametros := '-qqq ' + MontarOpcoes(AForm) +
              ' -o' + Saida + #32 + Entrada;

    AForm.Status('Compactando...');
    AForm.lblStatusDetalhe.Caption := EmptyStr;
    AForm.Repaint;
    Exec := TThrExecutar.Create(AForm);
    Exec.Arquivo := UPX;
    Exec.Parametros := Parametros;
    Exec.Resume;
  finally

  end;
end;

end.
