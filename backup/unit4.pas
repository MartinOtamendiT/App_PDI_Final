unit Unit4;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Spin, Buttons;

type

  { TForm4 }

  TForm4 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    FloatSpinEdit1: TFloatSpinEdit;
    procedure BitBtn1Click(Sender: TObject);
  private

  public
    //Procedimiento que inicializa valores en el form 4.
    procedure init();
  end;

var
  Form4: TForm4;

implementation

{$R *.lfm}

procedure TForm4.BitBtn1Click(Sender: TObject);
begin

end;

//Procedimiento que inicializa valores en el form 3.
procedure TForm4.init();
begin
  FloatSpinEdit1.Value := 0.01;
end;

end.

