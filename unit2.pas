unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, Buttons,
  StdCtrls, math;

type

  { TForm2 }

  TForm2 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    TrackBar1: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private

  public
    //Procedimiento que recibe parámetros del formulario 1.
    procedure setParameters(ANCHO, ALTO: Integer);
  end;

var
  Form2: TForm2;
  //Dimensiones de la imagen.
  ALTO2, ANCHO2   : Integer;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.FormCreate(Sender: TObject);
begin

end;

procedure TForm2.TrackBar1Change(Sender: TObject);
begin
  Label1.Caption := IntToStr(TrackBar1.Position);
end;

//Procedimiento que recibe parámetros del formulario 1.
procedure TForm2.setParameters(ANCHO, ALTO: Integer);
begin
  ANCHO2 := ANCHO;
  ALTO2 := ALTO;
  TrackBar1.Max := min(ANCHO2, ALTO2);
  TrackBar1.Min := 3;
  TrackBar1.Position := TrackBar1.Min;
  Label1.Caption := IntToStr(TrackBar1.Position);
end;

end.
