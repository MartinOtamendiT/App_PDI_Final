unit Unit5;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls;

type

  { TForm5 }
  //Matriz Tri-dimensional para almacenar contenido de imagen.
  MATRGB = Array of Array of Array of Byte;

  TForm5 = class(TForm)
    Image1: TImage;
    ScrollBox1: TScrollBox;
  private

  public

  end;

var
  Form5: TForm5;

implementation

{$R *.lfm}

end.

