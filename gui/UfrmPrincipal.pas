unit UfrmPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

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
    procedure btnEscolherArquivoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bmMetodoChange(Sender: TObject);
  private
    { Private declarations }
  public
    procedure AtualizarTamanho;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

procedure TfrmPrincipal.AtualizarTamanho;
begin
  if not pnlAvancado.Visible then
    frmPrincipal.Height := pnlTopo.Height + pnlBase.Height + 30
  else
    frmPrincipal.Height := pnlTopo.Height + pnlBase.Height + pnlAvancado.Height + 30;
end;

procedure TfrmPrincipal.bmMetodoChange(Sender: TObject);
begin
  if bmMetodo.ItemIndex = 5 then
    pnlAvancado.Show;
  AtualizarTamanho;
end;

procedure TfrmPrincipal.btnEscolherArquivoClick(Sender: TObject);
begin
  if odEscolherArquivo.Execute(Self.Handle) then
  begin
    btnEscolherArquivo.Caption := odEscolherArquivo.FileName;
  end;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  AtualizarTamanho;
end;

end.
