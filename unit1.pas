unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids;

type

  { TForm1 }

  TForm1 = class(TForm)
    StringGrid1: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid1EditingDone(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

type
  ceny = record
    nazov: string;
    kod: integer;
    nak: currency;
    pred: currency;
  end;

var
  Form1: TForm1;
  tovar: TextFile;
  cennik: TextFile;
  cena: array of ceny;
  x,xc: integer;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var i,j: integer;
    c: char;
    kod_temp: string;
    cena_temp: string;
begin
  DecimalSeparator := '.';

  StringGrid1.Cells[0,0] := 'Kod';
  StringGrid1.Cells[1,0] := 'Tovar';
  StringGrid1.Cells[2,0] := 'Nak. cena';
  StringGrid1.Cells[3,0] := 'Pred. cena';
  StringGrid1.ColWidths[0] := 50;
  StringGrid1.ColWidths[1] := 200;
  StringGrid1.ColWidths[2] := 100;
  StringGrid1.ColWidths[3] := 100;
  StringGrid1.Width := StringGrid1.ColWidths[0] + StringGrid1.ColWidths[1] + StringGrid1.ColWidths[2] + StringGrid1.ColWidths[3];

  AssignFile(tovar,'TOVAR.txt');
  Reset(tovar);
  ReadLn(tovar,x);
  SetLength(cena,x+1);
  StringGrid1.RowCount := x+1;
  for i := 1 to x do
      begin
        Read(tovar,c);
        repeat
          IF c in ['0'..'9']
             THEN kod_temp := kod_temp + c;
          Read(tovar,c);
        until c = ';';
        cena[i].kod := StrToInt(kod_temp);
        StringGrid1.Cells[0,i] := kod_temp;

        //Read(tovar,c);
        repeat
          Read(tovar,c);
          cena[i].nazov := cena[i].nazov + c;
        until EoLn(tovar);

        StringGrid1.Cells[1,i] := cena[i].nazov;

        kod_temp := '';
      end;
  CloseFile(tovar);

  IF NOT FileExists('CENNIK.txt')
     THEN begin
                 AssignFile(cennik,'CENNIK.txt');
                 ReWrite(cennik);
                 WriteLn(cennik,'0');
                 for i := 1 to x do
                     begin
                       cena[i].nak := 0;
                       cena[i].pred := 0;
                       StringGrid1.Cells[2,i] := FloatToStr(cena[i].nak);
                       StringGrid1.Cells[3,i] := FloatToStr(cena[i].pred);
                       WriteLn(cennik,IntToStr(cena[i].kod)+';'+FloatToStr(cena[i].nak)+';'+FloatToStr(cena[i].pred));
                     end;
                 CloseFile(cennik);
               end
          ELSE begin
                 AssignFile(cennik,'CENNIK.txt');
                 Reset(cennik);
                 ReadLn(cennik,xc);
                 for i := 1 to xc do
                     begin
                       j := 0;

                       Read(cennik,c);
                       repeat
                         IF c in ['0'..'9']
                            THEN kod_temp := kod_temp + c;
                       Read(cennik,c);
                       until c = ';';

                       repeat
                         inc(j);
                       until StrToInt(kod_temp) = cena[j].kod;
                       kod_temp := '';

                       Read(cennik,c);
                       repeat
                         cena_temp := cena_temp + c;
                         Read(cennik,c);
                       until c = ';';
                       cena[j].nak := StrToFloat(cena_temp);
                       cena_temp := '';

                       Read(cennik,c);
                       repeat
                         cena_temp := cena_temp + c;
                         Read(cennik,c);
                       until EoLn(cennik);
                       cena[j].pred := StrToFloat(cena_temp);
                       cena_temp := '';
                     end;

            for i := 1 to x do
                IF cena[i].nak = null
                   THEN begin
                          cena[i].nak := 0;
                          cena[i].pred := 0;
                        end;

            CloseFile(cennik);

            ReWrite(cennik);
            WriteLn(cennik,x);
            for i := 1 to x do
                begin
                  WriteLn(cennik,IntToStr(cena[i].kod)+';'+FloatToStr(cena[i].nak)+';'+FloatToStr(cena[i].pred));
                  StringGrid1.Cells[2,i] := FloatToStr(cena[i].nak);
                  StringGrid1.Cells[3,i] := FloatToStr(cena[i].pred);
                end;

            CloseFile(cennik);
          end;
end;

procedure TForm1.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var i: integer;
begin
  for i := 1 to x do
      IF cena[i].nak = 0
         THEN begin
                aRow := i;
                StringGrid1.Canvas.Brush.Color := clRed;
                StringGrid1.Canvas.FillRect(aRect);
                StringGrid1.Canvas.TextRect(aRect,aRect.Left,aRect.top,StringGrid1.Cells[aCol,aRow]);
              end;
end;

procedure TForm1.StringGrid1EditingDone(Sender: TObject);
begin
  ShowMessage('YAAAAAAS');
end;

end.
