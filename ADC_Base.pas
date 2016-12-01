{************************************************************}
{                                                            }
{                 ������ ���                                 }
{       Copyright (c) 2001  ��� ����                         }
{               �����/������                                 }
{                                                            }
{  �����������: �� ��                                        }
{  �������������: 26 ������ 2008                             }
{                                                            }
{************************************************************}
unit ADC_Base;

interface

uses
  Windows,
  Lcard, CommonTypes;

type
  PTAdcBase = ^TAdcBase;
  TAdcBase = class
  private
    FPlata: TPlata;                             // ������ �� ����� �20-10
    FFrequency: WORD;                           // ������� ���
    FDuration: WORD;                            // ����� ��������� (������ �����) � ��
  //  FStatus: Boolean;                           // ���������� �����
    procedure SetFrequency(const Value: WORD);
    procedure SetDuration(const Value: WORD);
    procedure MakeControlTable; virtual;         // ���������� ����������� ������� ��� ���
  protected
    //
  public
    constructor Create(Plata: TPlata);                         // �����������
    procedure Prepare;                          //���������� � ������
    function Ready: Boolean;                    //���������� ���
    property Frequency: WORD read FFrequency write SetFrequency;
    property Duration: WORD read FDuration write SetDuration;
//    property Ready: Boolean read FStatus;
  end;

  TAdcLevelSignal = class(TAdcBase)
  private
    FLogicalChannel: TLogicalCnannel;
    procedure SetChannel(const Value: TLogicalCnannel);
    procedure MakeControlTable; override;
  public
    function GetLevelSignalInVolt: Double;      // �������� ������� �������� ������ � �������
    function GetLevelSignalInQuant: SHORT;      // �������� ������� �������� ������ � ���������
    property ChannelLevel: TLogicalCnannel read FLogicalChannel write SetChannel;
  end;

  TAdcSpectr = class(TAdcBase)
  private
    FLogicalChannelField: TLogicalCnannel;
    FLogicalChannelSignal: TLogicalCnannel;
    procedure SetChannelField(const Value: TLogicalCnannel);
    procedure SetChannelSignal(const Value: TLogicalCnannel);
    procedure MakeControlTable; override;
  public
    procedure Start;
    function GetDataOfChannel(ChannelNumber: WORD): TADC_DATA;   // �������� ������ �� ������ (1..4)
    property ChannelField: TLogicalCnannel read FLogicalChannelField write SetChannelField;
    property ChannelSignal: TLogicalCnannel read FLogicalChannelSignal write SetChannelSignal;
  end;


implementation

//==================================================

constructor TAdcBase.Create(Plata: TPlata);
begin
  inherited Create;
  FPlata := Plata;
//  FStatus := FPlata.IsReady;
end;

//--------------------------------------------------

procedure TAdcBase.SetDuration(const Value: WORD);
begin
  FDuration := Value;
end;

procedure TAdcBase.SetFrequency(const Value: WORD);
begin
  FFrequency := Value;
end;

//--------------------------------------------------

procedure TAdcBase.Prepare;
begin
  MakeControlTable;
  FPlata.RateAdc := FFrequency;
  FPlata.DuratoinSignal := FDuration;
  FPlata.Fill_ADC_PARS_2010;
end;

//==================================================


{ TAdcLevelSignal }

function TAdcLevelSignal.GetLevelSignalInQuant: SHORT;
var
  i: longint;
  Value: SHORT;
  Channel: WORD;
begin
  FPlata.Start_ADC;
  Channel := FlogicalChannel.Number - 1;
  Value := 0;
  for i := 0 to Length(FPlata.AdcDataArray[Channel]) - 1 do
  begin
    Value := Value + FPlata.AdcDataArray[Channel][i].quantization_step;
  end;
  Result := ABS(Value div Length(FPlata.AdcDataArray[Channel]));
end;

//--------------------------------------------------

function TAdcLevelSignal.GetLevelSignalInVolt: Double;
var
  i: longint;
  Value: double;
  Channel: WORD;
begin
  if not FPlata.IsReady then
  begin
    Result := 0;
    exit;
  end;
  if FPlata.Start_ADC then
  begin
    Channel := FlogicalChannel.Number - 1;
    Value := 0;
    for i := 0 to Length(FPlata.AdcDataArray[Channel]) - 1 do
    begin
      Value := Value + FPlata.AdcDataArray[Channel][i].voltage;
    end;
    //Result := ABS(Value / Length(FPlata.AdcDataArray[Channel]));
    Result := Value / Length(FPlata.AdcDataArray[Channel]);
  end;
end;

//--------------------------------------------------

procedure TAdcLevelSignal.MakeControlTable;
begin
  inherited;
  FPlata.ClearControlTable;
  FPlata.AddChannel(FLogicalChannel);
end;

procedure TAdcLevelSignal.SetChannel(const Value: TLogicalCnannel);
begin
  FLogicalChannel := Value;
end;

{ TAdcSpectr }

function TAdcSpectr.GetDataOfChannel(ChannelNumber: WORD): TADC_DATA;
var
  i: longint;
  Channel: WORD;
  DataArray: TADC_DATA;
begin
  Channel := ChannelNumber - 1;
  SetLength(DataArray, Length(FPlata.AdcDataArray[Channel]));
  for i := 0 to Length(FPlata.AdcDataArray[Channel]) - 1 do
  begin
    DataArray[i] := FPlata.AdcDataArray[Channel][i];
  end;
  Result := DataArray;
end;

//--------------------------------------------------

procedure TAdcSpectr.MakeControlTable;
begin
  inherited;
  FPlata.ClearControlTable;
  FPlata.AddChannel(FLogicalChannelField);
  FPlata.AddChannel(FLogicalChannelSignal);
end;

procedure TAdcSpectr.SetChannelField(const Value: TLogicalCnannel);
begin
  FLogicalChannelField := Value;
end;

//--------------------------------------------------

procedure TAdcSpectr.SetChannelSignal(const Value: TLogicalCnannel);
begin
  FLogicalChannelSignal := Value;
end;

//--------------------------------------------------

procedure TAdcSpectr.Start;
begin
  FPlata.Start_ADC;
end;

//--------------------------------------------------

procedure TAdcBase.MakeControlTable;
begin
//
end;

function TAdcBase.Ready: Boolean;
begin
  Result := FPlata.IsReady;
end;

end.
