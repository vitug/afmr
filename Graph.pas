{************************************************************}
{                                                            }
{                 Модуль ХХХ                                 }
{       Copyright (c) 2001  ООО ХХХХ                         }
{               отдел/сектор                                 }
{                                                            }
{  Разработчик: ХХ ХХ                                        }
{  Модифицирован: 25 июня 2001                               }
{                                                            }
{************************************************************}
unit Graph;

interface

uses
  Types, TeeProcs, TeEngine, Graphics, Chart, Series, Dialogs,
  Windows, StdCtrls, SysUtils,
  Spectrm, Sp_Unit, CommonTypes;

const
  SpectrumViewMode = 0;
  PulseViewMode = 1;

type
  TGraph = class
  private
    FChart: TChart;
    FBigChart: TChart;
    FSpectrometer: TSpectrometer;
    FSpectrDescription: TSpectrDescription;
    FShowLine: boolean;
    FXBeginPulse: real;
    FXBeginPulseStat: real;
    FUserXBeginPulse: real;
    FDeltaT: real;  //разница между определен. автоматически началом импульса и указанным пользователем
    FWhatView: integer; //1-Adc; 0-spectr
  public
    constructor Create(SmallChart, BigChart: TChart; Sp: TSpectrometer);
    function FindMax: real;
    function FindMin: real;
    procedure SetUserBeginPulse;
    procedure ViewSpectr;
    procedure ViewPulse;
    procedure Clear;
    procedure Swap;                       //переключает спектр/импульс
    procedure FindMinMax(ViewFrom, ViewTill: integer);
    procedure ShowBeginPulse;
    function NextSpectrum: Boolean;
    function PrevSpectrum: Boolean;
    function NextPulse: Boolean;
    function PrevPulse: Boolean;
    property WhatView: integer read FWhatView write FWhatView;
    property ShowLine: boolean read FShowLine write FShowLine;
    property SpectrDescription: TSpectrDescription read FSpectrDescription;
end;

implementation

//uses
  //Classes;

//==================================================

constructor TGraph.Create(SmallChart, BigChart: TChart; Sp: TSpectrometer);
begin
  //инициализация свойств происходит в модуле формы
  FChart := SmallChart;
  FBigChart := BigChart;
  FSpectrometer := Sp;
end;

//--------------------------------------------------

procedure TGraph.Clear;
begin
//
end;

//--------------------------------------------------

procedure TGraph.ViewSpectr;
var
  i:   integer;
  x, y, max: real;
  Spectr: TSpectrum;
begin
  if (FSpectrometer.Sb <> nil) and (FSpectrometer.Sb.GetCurrent <> nil) then
  begin
    FChart.UndoZoom;
    FBigChart.UndoZoom;
    FChart.Series[0].Clear;
    FBigChart.Series[0].Clear;
    FBigChart.Series[1].Clear;
    FBigChart.BottomAxis.Automatic := True;
    FBigChart.LeftAxis.Automatic := True;
    Spectr := FSpectrometer.Sb.GetCurrent;
    Max := 0;

    {Чарт быстро выводит данные по возрастанию оси Х
     поэтому проверяем какая часть импульса разворачивается
     и делаем соответствующее направление цикла}
    if Spectr.SpectrDescription.FrontBack = fbFront then
    begin
      for i := Low(Spectr.SpectrData) to High(Spectr.SpectrData) do
      begin
        x := Spectr.SpectrData[i].x;
        y := Spectr.SpectrData[i].y.Voltage;
        FChart.Series[0].AddXY(x, y);
        FBigChart.Series[0].AddXY(x, y);
      end;
    end;

    if Spectr.SpectrDescription.FrontBack = fbBack then
    begin
      for i := High(Spectr.SpectrData) downto Low(Spectr.SpectrData) do
      begin
        x := Spectr.SpectrData[i].x;
        y := Spectr.SpectrData[i].y.Voltage;
        FChart.Series[0].AddXY(x, y);
        FBigChart.Series[0].AddXY(x, y);
      end;
    end;

    FSpectrDescription := Spectr.SpectrDescription;

    FShowLine := False;
    FChart.Refresh;
    FBigChart.Refresh;
    Self.FWhatView := SpectrumViewMode;
  end;
end;

//--------------------------------------------------

function testFunc(i: integer): integer;
begin
  if i < 1000 then
    Result := 0
  else
    Result := i;
end;

//--------------------------------------------------

procedure TGraph.ViewPulse;
var
  i:   integer;
  x, y, bp: real;
  Spectr: Tspectrum;
  From, Till: extended;
  res: Double;
begin
  if (FSpectrometer.Sb <> nil) and (FSpectrometer.Sb.GetCurrent <> nil) then
  begin
    FBigChart.UndoZoom;
    FBigChart.Series[0].Clear;
    FBigChart.Series[1].Clear;
    FBigChart.BottomAxis.Automatic := True;
    FBigChart.LeftAxis.Automatic := True;
    Spectr := FSpectrometer.Sb.GetCurrent;
    for i := Low(Spectr.PulseData) to High(Spectr.PulseData) do
    begin
      x := Spectr.PulseData[i].time;
      y := Spectr.PulseData[i].voltage;
      //y := Spectr.PulseData[i].quantization_step;
      FBigChart.Series[0].AddXY(x, y);
      FBigChart.Series[1].AddXY(x,
        FSpectrometer.PulseGenerator.GetFitValue(x, Spectr.SpectrDescription.ChargeVoltage,
        Spectr.ParamCircuit_Fit));
    end;

    //FindMinMax(Round(From),Round(Till));
    //FShowLine := True;
    FBigChart.Refresh;
    Self.FWhatView := PulseViewMode;
    //FUserXBeginPulse := 0;
  end;

end;

//--------------------------------------------------

procedure TGraph.Swap;
begin
  case FWhatView of
    SpectrumViewMode: ViewPulse;
    PulseViewMode: ViewSpectr;
  end;
end;

//--------------------------------------------------

function TGraph.FindMax: real;
var
  MinX, MaxX, MinY, MaxY: real;
  ViewFrom, ViewTill, MaxI: integer;
  i: word;
  SpectrData: TSpectrData;
begin
  {ViewFrom := FBigChart.Series[0].FirstValueIndex;
  ViewTill := FBigChart.Series[0].LastValueIndex;

  if ViewFrom or ViewTill = -1 then
  begin
    Result := 0;
    exit;
  end;

  SpectrData := FSpectrometer.SB.GetCurrent.SpectrData;

  MaxY := SpectrData[ViewFrom].y.Voltage;
  MaxI := ViewFrom;
  for i := ViewFrom to ViewTill do
  begin
    if SpectrData[i].y.Voltage > MaxY then
    begin
      MaxY := SpectrData[i].y.Voltage;
      MaxI := i;
    end;
  end;
  Result := SpectrData[MaxI].x; }
end;

//--------------------------------------------------

function TGraph.FindMin: real;
var
  MinX, MaxX, MinY, MaxY: real;
  ViewFrom, ViewTill, MinI: integer;
  i: word;
  SpectrData: TSpectrData;
begin
  {ViewFrom := FBigChart.Series[0].FirstValueIndex;
  ViewTill := FBigChart.Series[0].LastValueIndex;
  if ViewFrom or ViewTill = -1 then
  begin
    Result := 0;
    exit;
  end;
  SpectrData := FSpectrometer.SB.GetCurrent.SpectrData;
  MinY := SpectrData[ViewFrom].y.Voltage;
  MinI := ViewFrom;
  for i := ViewFrom to ViewTill do
  begin
    if SpectrData[i].y.Voltage < MinY then
    begin
      MinY := SpectrData[i].y.Voltage;
      MinI := i;
    end;
  end;
  Result := SpectrData[MinI].x; }
end;

//--------------------------------------------------

procedure TGraph.FindMinMax(ViewFrom, ViewTill: integer);
{var
  MinX, MaxX, MinY, MaxY, MaxI: real;
  i: word;
  GraphData: PTAdcBase; }

begin
  {GraphData := FSpectrometer.AdcField;
  if GraphData <> nil then
  begin
    with GraphData^ do
      begin
        if High(Data) < 1 then
          exit; 
        MinY := Data[ViewFrom].Volt;
        MaxY := Data[ViewFrom].Volt;
        MaxI := ViewFrom;
        for i := ViewFrom + 1 to ViewTill do
        begin
          if Data[i].Volt > MaxY then
            begin
              MaxY := Data[i].Volt;
              MaxI := i;
            end;
          if Data[i].Volt < MinY then
            MinY := Data[i].Volt;
        end;
        FBigChart.LeftAxis.SetMinMax(MinY, MaxY);
      end;
  end;  }
end;

//--------------------------------------------------

procedure TGraph.SetUserBeginPulse;
{var
  coord: TPoint; }
begin
 { if self.FWhatView = PulseViewMode then
  begin
    coord := FBigChart.GetCursorPos;
    self.FUserXBeginPulse := FBigChart.Series[1].XScreenToValue(coord.X);
    FDeltaT := FUserXBeginPulse - FXBeginPulse;
    FSpectrometer.RecalcSpectrum(FDeltaT);
  end;  }
end;

//--------------------------------------------------

procedure TGraph.ShowBeginPulse;
var
  xpos: integer;
  bp: real;
  S: string;
  MaxX: real;
  MinX: real;
begin
  if FShowLine then
  begin
    bp := FXBeginPulseStat;
    xpos := FBigChart.Series[1].CalcXPosValue(FXBeginPulse);
    FBigChart.Canvas.Pen.Color := clred;
    FBigChart.Canvas.MoveTo(xpos, FBigChart.Height);
    FBigChart.Canvas.LineTo(xpos, 0);
    FBigChart.Canvas.Pen.Color := clGreen;
    xpos := FBigChart.Series[1].CalcXPosValue(FXBeginPulseStat);
    FBigChart.Canvas.MoveTo(xpos, FBigChart.Height);
    FBigChart.Canvas.LineTo(xpos, 0);
    if FUserXBeginPulse > 0 then
    begin
      bp := FUserXBeginPulse;
      FBigChart.Canvas.Pen.Color := clBlack;
      xpos := FBigChart.Series[1].CalcXPosValue(FUserXBeginPulse);
      FBigChart.Canvas.MoveTo(xpos, FBigChart.Height);
      FBigChart.Canvas.LineTo(xpos, 0);
    end;
    FBigChart.Canvas.Pen.Color := clBlack;
    FBigChart.Canvas.Brush.Color := FBigChart.Color;
    FBigChart.Canvas.Font.Height := 14;
    xpos := FBigChart.Series[1].CalcXPosValue(FXBeginPulse);
    Str(bp:5:2,S);
    FBigChart.Canvas.TextOut(10, 2, 'Начало импульса= ' + S)
  end
  else
  begin
    FBigChart.Canvas.Pen.Color := clBlack;
    FBigChart.Canvas.Brush.Color := FBigChart.Color;
    FBigChart.Canvas.Font.Height := 14;
    MaxX := FindMax;
    MinX := FindMin;
    Str(MaxX:5:2,S);
    FBigChart.Canvas.TextOut(10, 2, 'Максимум= '+ S + ' кЭ');
    Str(MinX:5:2,S);
    FBigChart.Canvas.TextOut(10,16,'Минимум = '+ S + ' кЭ');
  end;
end;

//--------------------------------------------------

function TGraph.NextSpectrum: Boolean;
begin
  Result := self.FSpectrometer.NextSpectrum;
  self.ViewSpectr;
end;

//--------------------------------------------------

function TGraph.PrevSpectrum: Boolean;
begin
  Result := self.FSpectrometer.PrevSpectrum;
  self.ViewSpectr;
end;

//--------------------------------------------------

function TGraph.NextPulse: Boolean;
begin
  Result := self.FSpectrometer.NextSpectrum;
  self.ViewPulse;
end;

//--------------------------------------------------

function TGraph.PrevPulse: Boolean;
begin
  Result := self.FSpectrometer.PrevSpectrum;
  self.ViewPulse;
end;

//==================================================

end.
