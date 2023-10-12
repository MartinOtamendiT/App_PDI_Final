unit Unit3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Spin, Buttons;

type

  { TForm3 }

  TForm3 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    FloatSpinEdit1: TFloatSpinEdit;
    Label1: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FloatSpinEdit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private

  public
    //Procedimiento que inicializa valores en el form 3.
    procedure init();
  end;

var
  Form3: TForm3;

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.Edit1Change(Sender: TObject);
begin

end;

procedure TForm3.BitBtn1Click(Sender: TObject);
begin

end;

procedure TForm3.FloatSpinEdit1Change(Sender: TObject);
begin

end;

procedure TForm3.FormCreate(Sender: TObject);
begin

end;

procedure TForm3.Label1Click(Sender: TObject);
begin

end;

//Procedimiento que inicializa valores en el form 3.
procedure TForm3.init();
begin
  FloatSpinEdit1.Value := 0.00;
end;

end.

