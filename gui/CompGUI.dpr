program CompGUI;

{$R *.dres}

uses
  Forms,
  UfrmPrincipal in 'UfrmPrincipal.pas' {frmPrincipal},
  UComprimir in 'UComprimir.pas',
  UthrExecutar in 'UthrExecutar.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
