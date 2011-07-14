unit UfrmPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, GIFImg;

type
  TfrmPrincipal = class(TForm)
    odEscolherArquivo: TOpenDialog;
    pnlTopo: TPanel;
    btnEscolherArquivo: TSpeedButton;
    lblArquivo: TLabel;
    lblMetodo: TLabel;
    bmMetodo: TComboBox;
    pnlBase: TPanel;
    btnIniciar: TButton;
    pnlAvancado: TPanel;
    lblExport: TLabel;
    cbCompressExport: TComboBox;
    lblIcones: TLabel;
    cbCompressIcons: TComboBox;
    lblResources: TLabel;
    cbResources: TComboBox;
    lblStripReloc: TLabel;
    cbStripRelocs: TComboBox;
    cbForced: TCheckBox;
    cbAllMethods: TCheckBox;
    cbAllFilters: TCheckBox;
    lblOverlay: TLabel;
    cbOverlay: TComboBox;
    lblNivel: TLabel;
    tbrNivel: TTrackBar;
    lblNivelValor: TLabel;
    lblTuning: TLabel;
    cbMetodo: TComboBox;
    pnlExecutando: TPanel;
    Image1: TImage;
    lblStatus: TLabel;
    procedure btnEscolherArquivoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bmMetodoChange(Sender: TObject);
    procedure tbrNivelChange(Sender: TObject);
    procedure btnIniciarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure CarregarGIF;
    procedure SetupGUI(Estado: Integer);
  public
    procedure AtualizarTamanho;
    procedure Status(Mensagem: string);
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
  UComprimir;

{$R *.dfm}

procedure TfrmPrincipal.AtualizarTamanho;
begin
  if not pnlAvancado.Visible then
    frmPrincipal.Height := pnlTopo.Height + pnlBase.Height + 30
  else
    frmPrincipal.Height := pnlTopo.Height + pnlBase.Height + 276;
end;

procedure TfrmPrincipal.bmMetodoChange(Sender: TObject);
begin
  pnlAvancado.Visible := bmMetodo.ItemIndex = 5;
  AtualizarTamanho;
end;

procedure TfrmPrincipal.btnEscolherArquivoClick(Sender: TObject);
begin
  if odEscolherArquivo.Execute(Self.Handle) then
  begin
    btnEscolherArquivo.Caption := odEscolherArquivo.FileName;
  end;
end;

procedure TfrmPrincipal.btnIniciarClick(Sender: TObject);
begin
  if btnEscolherArquivo.Caption = '(escolher arquivo)' then
  begin
    MessageDlg('Você precisa escolher um arquivo para compactar.',
      mtError, [mbOK], 0);
    Exit;
  end;

  Status('Iniciando...');
  SetupGUI(0);
  Comprimir(Self);
end;

procedure TfrmPrincipal.CarregarGIF;
var
  gif: TGIFImage;
  res: TResourceStream;
begin
  res := TResourceStream.Create(HInstance, 'processando', RT_RCDATA);
  try
    gif := TGIFImage.Create;
    gif.LoadFromStream(res);
    gif.Animate := true;
    Image1.Picture.Assign(gif);
  finally
    res.Free;
  end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  CarregarGIF;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  AtualizarTamanho;
end;

procedure TfrmPrincipal.SetupGUI(Estado: Integer);
begin
  case Estado of
    0:
      begin
        pnlAvancado.Hide;
        pnlTopo.Hide;
        pnlBase.Hide;
        pnlExecutando.Show;
        frmPrincipal.Height := 120;
      end;
    1:
      begin
        pnlExecutando.Hide;
        pnlTopo.Show;
        pnlBase.Show;
        bmMetodoChange(bmMetodo);
        AtualizarTamanho;
      end;
  end;
end;

procedure TfrmPrincipal.Status(Mensagem: string);
begin
  lblStatus.Caption := Mensagem;
end;

procedure TfrmPrincipal.tbrNivelChange(Sender: TObject);
begin
  lblNivelValor.Caption := IntToStr(TTrackBar(Sender).Position);
end;

end.
