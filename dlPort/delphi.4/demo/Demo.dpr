program Demo;

uses
  Forms,
  Main in 'Main.pas' {Main_Win};

{$E exe}

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'DriverLINX wrapper component demo';
  Application.CreateForm(TMain_Win, Main_Win);
  Application.Run;
end.
