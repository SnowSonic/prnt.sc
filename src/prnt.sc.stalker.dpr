program prnt.sc.stalker;

uses
  FastMM4,
  Vcl.Forms,
  Main in 'Main.pas' {fmMain};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
