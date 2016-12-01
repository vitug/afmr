{************************************************************}
{                                                            }
{                 Модуль ХХХ                                 }
{       Copyright (c) 2001  ООО ХХХХ                         }
{               отдел/сектор                                 }
{                                                            }
{  Разработчик: ХХ ХХ                                        }
{  Модифицирован: 10 декабря 2008                            }
{                                                            }
{************************************************************}
unit viewspc;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, TeeProcs, TeEngine, Chart, Series,
  StdCtrls,
  Graph, CommonTypes;

type
  TFormView = class(TForm)
    BigChart: TChart;
    Series1: TFastLineSeries;
    PanelView: TPanel;
    Temp: TLabel;
    Freq: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    ViewSpectr: TButton;
    XEdit: TEdit;
    YEdit: TEdit;
    StateLabel: TLabel;
    CloseButton: TButton;
    ButtonPanel: TPanel;
    PrevBt: TButton;
    NextBt: TButton;
    AngleLabel: TLabel;
    Series2: TFastLineSeries;
    procedure ViewSpectrClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BigChartMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure BigChartAfterDraw(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure BigChartClick(Sender: TObject);
    procedure PrevBtClick(Sender: TObject);
    procedure NextBtClick(Sender: TObject);
  private
    { Private declarations }
    FGraph: TGraph;
  public
    { Public declarations }
    property Graph: TGraph write FGraph;
  end;

var
  FormView: TFormView;

implementation

{$R *.dfm}
uses
  Main;
//==================================================

procedure TFormView.ViewSpectrClick(Sender: TObject);
begin
  FGraph.Swap;
  case FGraph.WhatView of
    0:
      Begin
        StateLabel.Caption := 'Просмотр спектра';
        FocusControl(CloseButton);
      end;
    1:
      Begin
        StateLabel.Caption := 'Просмотр импульса';
        self.FocusControl(ViewSpectr);
      end;
  end;
end;

//--------------------------------------------------

procedure TFormView.FormShow(Sender: TObject);
begin
  FGraph.ViewSpectr;
  StateLabel.Caption := 'Просмотр спектра';
  FocusControl(CloseButton);
end;

//--------------------------------------------------

procedure TFormView.BigChartMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  CX, CY: real;
begin
  CX := BigChart.Series[0].XScreenToValue(X);
  XEdit.Text := FloatToStrF(CX, ffGeneral, 4, 4);
  CY := BigChart.Series[0].YScreenToValue(Y);
  YEdit.Text := FloatToStrF(CY, ffGeneral, 4, 4);
end;

//--------------------------------------------------

procedure TFormView.BigChartAfterDraw(Sender: TObject);
begin
  with FGraph.SpectrDescription do
  begin
    Temp.Caption := 'T= ' + FloatToStrF(Temperature, ffFixed, 10, 2, FormatSettings);
    Freq.Caption := 'F= ' + FloatToStrF(Frequency, ffFixed, 10, 2, FormatSettings);
    AngleLabel.Caption := 'A= ' + FloatToStrF(Angle, ffFixed, 10, 2, FormatSettings);
  end;
  FGraph.ShowBeginPulse;
end;

//--------------------------------------------------

procedure TFormView.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

//--------------------------------------------------

procedure TFormView.BigChartClick(Sender: TObject);
begin
  FGraph.SetUserBeginPulse;
  BigChart.Repaint;
end;

//--------------------------------------------------

procedure TFormView.PrevBtClick(Sender: TObject);
begin
  case FGraph.WhatView of
  SpectrumViewMode:
    FGraph.PrevSpectrum;
  PulseViewMode:
    FGraph.PrevPulse;
  end;
end;

//--------------------------------------------------

procedure TFormView.NextBtClick(Sender: TObject);
begin
  case FGraph.WhatView of
  SpectrumViewMode:
    FGraph.NextSpectrum;
  PulseViewMode:
    FGraph.NextPulse;
  end;
end;

//==================================================

end.
