unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  LCLType, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  ExtCtrls, StdCtrls, Buttons;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn2: TBitBtn;
    Edit1: TEdit;
    Label1: TLabel;
    StringGrid1: TStringGrid;
    procedure BitBtn2Click(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid1EditingDone(Sender: TObject);
    procedure reWritePrices();
    procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
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
  path: string;
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
  StringGrid1.Options := StringGrid1.Options - [goEditing];
  //StringGrid1.ColumnClickSorts := false;
  path := '';
  StringGrid1.SelectedColor:=clHighlight;
  //StringGrid1.Options := StringGrid1.Options - [goDrawFocusSelected];


  StringGrid1.Cells[0,0] := 'Kod';
  StringGrid1.Cells[1,0] := 'Tovar';
  StringGrid1.Cells[2,0] := 'Nak. cena';
  StringGrid1.Cells[3,0] := 'Pred. cena';
  StringGrid1.ColWidths[0] := 50;
  StringGrid1.ColWidths[1] := 200;
  StringGrid1.ColWidths[2] := 100;
  StringGrid1.ColWidths[3] := 100;
  StringGrid1.Width := StringGrid1.ColWidths[0] + StringGrid1.ColWidths[1] + StringGrid1.ColWidths[2] + StringGrid1.ColWidths[3] + 18;

  AssignFile(tovar,path+'TOVAR.txt');
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

  IF NOT FileExists(path+'CENNIK.txt')
     THEN begin
                 AssignFile(cennik,path+'CENNIK.txt');
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
                 AssignFile(cennik,path+'CENNIK.txt');
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

                       {Read(cennik,c);
                       repeat
                         cena_temp := cena_temp + c;
                         Read(cennik,c);
                       until EoLn(cennik);}
                       ReadLn(cennik,cena_temp);
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

procedure TForm1.Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
var i: integer;
begin
  StringGrid1.Options := StringGrid1.Options + [goDrawFocusSelected];
  IF Key = VK_RETURN
     THEN begin
            for i := 1 to x do
                IF UpperCase(Edit1.Text) = UpperCase(cena[i].nazov)
                   THEN begin
                          StringGrid1.Row := i;
                          StringGrid1.Col := 2;
                          //StringGrid1.OnSelectCell(self,i,2,true);
                          StringGrid1.SetFocus;
                          //StringGrid1.SelectedIndex := [i,2];
                        end;
          end;
  StringGrid1.Options := StringGrid1.Options - [goDrawFocusSelected];
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
  for i := 1 to x do
      IF UpperCase(Edit1.Text) = UpperCase(cena[i].nazov)
         THEN begin
                StringGrid1.Row := i;
                StringGrid1.Col := 2;
                //StringGrid1.OnSelectCell(self,i,2,true);
                StringGrid1.SetFocus;
                //StringGrid1.SelectedIndex := [i,2];
              end;
end;

procedure TForm1.StringGrid1DblClick(Sender: TObject);
begin
     IF (StringGrid1.Row > 0) AND (StringGrid1.Col > 1)
        THEN StringGrid1.Options := StringGrid1.Options + [goEditing];
end;

procedure TForm1.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var i,j: integer;
begin
            IF ((cena[aRow].nak = 0) OR (cena[aRow].pred = 0)) AND (aRow <> 0)
               THEN begin
                      //aRow := i;
                      //aCol := j;
                      StringGrid1.Canvas.Brush.Color := clRed;
                      StringGrid1.Canvas.FillRect(aRect);
                      StringGrid1.Canvas.TextRect(aRect,aRect.Left,aRect.top,StringGrid1.Cells[aCol,aRow]);
                    end
                    {ELSE IF aRow <> 0
                            THEN begin
                                   StringGrid1.Canvas.Brush.Color := clWhite;
                                   StringGrid1.Canvas.FillRect(aRect);
                                   StringGrid1.Canvas.TextRect(aRect,aRect.Left,aRect.top,StringGrid1.Cells[aCol,aRow]);
                                 end;}
end;

procedure TForm1.StringGrid1EditingDone(Sender: TObject);
begin
  //ShowMessage('YAAAAAAS');
  IF StringGrid1.Col = 2
     THEN cena[StringGrid1.Row].nak := StrToFloat(StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row])
          ELSE IF StringGrid1.Col = 3
                  THEN cena[StringGrid1.Row].pred := StrToFloat(StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row]);
  //@TForm1.StringGrid1DrawCell;
  StringGrid1.Options := StringGrid1.Options - [goEditing];
  reWritePrices();
end;

procedure TForm1.reWritePrices();
var i: integer;
begin
  ReWrite(cennik);
  WriteLn(cennik,x);
  for i := 1 to x do
      begin
        WriteLn(cennik,IntToStr(cena[i].kod)+';'+FloatToStr(cena[i].nak)+';'+FloatToStr(cena[i].pred));
        //StringGrid1.Cells[2,i] := FloatToStr(cena[i].nak);
        //StringGrid1.Cells[3,i] := FloatToStr(cena[i].pred);
      end;
  CloseFile(cennik);
end;

procedure TForm1.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin

end;

end.

