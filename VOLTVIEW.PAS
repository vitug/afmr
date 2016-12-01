Unit VoltView;
interface
uses Basic,Dos, Crt, Objects, Drivers, Memory, Views, Menus, Dialogs, App,
     GadGets, MsgBox, Calc, HelpFile, V_Meter,Spectrm;


type
    PTVoltView=^TVoltView;
    TVoltView=Object(TView)
        Voltmeter :PTVoltmeter;
        constructor Init(Bounds:TRect);
        procedure Update;
        procedure Draw; virtual;
        Destructor Done; virtual;
    end;
implementation

constructor TVoltView.Init(Bounds:TRect);
begin
     TView.Init(Bounds);
     GrowMode := gfGrowHiX + gfGrowHiY;
     VoltMeter:=New(PTVoltMeter,Init);
end;

procedure TVoltView.Update;
begin
     if Owner<>nil then
     Draw;
end;

procedure TVoltView.Draw;
var
   TS:string;
   Hmax,U:real;
   Pg:TPulseGenerator;
begin
     WriteStr(0,0,'Напряжение на батарее',2);
     Voltmeter^.Measure;
     if Voltmeter^.is_ready then
       if Voltmeter^.is_data then begin
         U:=Voltmeter^.U;
         Str(Voltmeter^.U:10:6,TS);
         WriteStr(0,1,'U= '+TS+'  V      ',2);
         if U>0 then begin
            Pg.InitDefault;
            Pg.SetVoltage(U);
            Hmax:=Pg.GetField(6E-3);
            Str(Hmax:5:3,TS);
            WriteStr(0,2,'Hmax= '+TS+'  kOe      ',2);
         end
         else
            WriteStr(0,2,'                       ',2);
        end
        else
       WriteStr(0,0,'No data!!!      ',2)
     else
        WriteStr(0,0,'No controller!!!      ',2);
end;

Destructor TVoltView.Done;
begin
     Dispose(Voltmeter,Done);
     TView.Done;
end;

end.