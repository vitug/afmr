program AFMR;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  viewspc in 'viewspc.pas' {FormView},
  Charger in 'Charger.pas',
  tempr_s in 'tempr_s.pas',
  v_meter in 'V_meter.pas',
  mathematic in 'Mathematic.pas',
  Basic in 'Basic.pas',
  spectrm in 'SPECTRM.PAS',
  sp_unit in 'SP_UNIT.PAS',
  CompareFormModule in 'CompareFormModule.pas' {CompareForm},
  M_Gauge in 'M_Gauge.pas',
  ProgrammOptions in 'ProgrammOptions.pas' {FormOptions},
  ADC_Base in 'ADC_Base.pas',
  Lcard in 'Lcard.pas',
  Lusbapi in 'Lusbapi.pas',
  FileParams in 'FileParams.pas',
  CommonTypes in 'CommonTypes.pas',
  FileRelis in 'FileRelis.pas',
  Graph in 'Graph.pas',
  UnitFormSummary in 'UnitFormSummary.pas' {FormSummary};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'AFMR spectrometer';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TFormView, FormView);
  Application.CreateForm(TCompareForm, CompareForm);
  Application.CreateForm(TFormOptions, FormOptions);
  Application.CreateForm(TFormSummary, FormSummary);
  Application.Run;
end.
