unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus, Unit2, Unit3,
  ExtDlgs, LCLIntf, ComCtrls, TAGraph, TASeries, math, TADrawUtils, TACustomSeries;

type



  { TForm1 }

  MATRGB = Array of Array of Array of Byte;  //Matriz Tri-dimensional para almacenar contenido de imagen.

  TForm1 = class(TForm)
    Chart1: TChart;
    GChannel: TLineSeries;
    BChannel: TLineSeries;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    RChannel: TLineSeries;
    Image1: TImage;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    ScrollBox1: TScrollBox;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure RChannelCustomDrawPointer(ASender: TChartSeries;
      ADrawer: IChartDrawer; AIndex: Integer; ACenter: TPoint);
  private

  public
    //Copiar de imagen a matriz con Canvas.
    procedure copiaIM(al,an: Integer; var M:MATRGB);
    //Copiar de BITmap a matriz con Scanline.
    procedure copBM(al,an:Integer; var M:MATRGB; B:Tbitmap);
    //Copiar de matriz a BITmap.
    procedure copMB(al,an: Integer; M:MATRGB; var B:Tbitmap);
    //Graficar histograma de la imagen.
    procedure grafHist();
    //Convierte la imagen a escala de grises.
    procedure toGray();
    //Aplica binarización dinámica a la imagen.
    procedure binarizar(r: Integer);
  end;

//Variables globales.
var
  Form1: TForm1;
  //Dimensiones de la imagen.
  ALTO, ANCHO   : Integer;
  MAT           :MATRGB;
  //Objeto orientado a directivas/metodos para .BMP.
  BMAP          :Tbitmap;

implementation

{$R *.lfm}

{ TForm1 }

//Conversión de RGB a HSV.
procedure TForm1.MenuItem2Click(Sender: TObject);
var
  i,j     :  Integer;
  cMin,cMax   : Real;
  diff        : Real;
  R,G,B       : Real;
  H,S,V       : Real;
begin
  for i:=0 to ALTO-1 do
  begin
    for j:=0 to ANCHO-1 do
    begin
      //Se convierten los valores RGB de 0-255 a 0-1.
      R := MAT[i,j,0]/255;
      G := MAT[i,j,1]/255;
      B := MAT[i,j,2]/255;
      //Se determina el mínimo entre R, G y B.
      cMin := min(min(R, G), B);
      //Se determina el máximo entre R, G y B.
      cMax := max(max(R, G), B);
      //Se calcula la diferencia entre el valor mínimo y el máximo.
      diff := cMax - cMin;

      //Calcula H.
      If cMax = cMin then
        H := 0
      else If cMax = R then
        H := (60 * ((G - B) / diff))
      else If cMax = G then
        H := (60 * ((B - R) / diff) + 120)
      else If cMax = B then
        H := (60 * ((R - G) / diff) + 240);
      //En caso de que H resulte negativo, es puesto en positivo.
      if(H < 0)then
        H := H + 360;

      //Calcula S.
      If cMax = 0 then
        S := 0
      else
        S := (diff / cMax) * 255;

      //Se calcula V.
      V := cMax * 255;

      //Se asignan HSV a los canales RGB.
      MAT[i,j,0] := Round(V);
      MAT[i,j,1] := Round(S);
      MAT[i,j,2] := Round(H/2); //360/2 = 180 para entrar en 8 bits.
    end; //j
  end; //i

  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT,BMAP);
  //Visualizar el resultado en pantalla.
  Image1.Picture.Assign(BMAP);
  //Se actualiza el histograma de la imagen.
  grafHist();
  //Se cambian los títulos de las series.
  BChannel.title := 'H';
  GChannel.title := 'S';
  RChannel.title := 'V';
  //Deshabilita conversión a HSV. Habilita conversión a RGB.
  MenuItem2.Enabled := False;
  MenuItem9.Enabled := True;
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin

end;

//Se abre imagen con ScanLine.
procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  if OpenPictureDialog1.execute  then
  begin
    Image1.Enabled:=True;
    BMAP.LoadFromFile(OpenPictureDialog1.FileName);
    ALTO:=BMAP.Height;
    ANCHO:=BMAP.Width;

    //Se garantizan los 8 bits por canal.
    if BMAP.PixelFormat<> pf24bit then
    begin
      BMAP.PixelFormat:=pf24bit;
    end;

    StatusBar1.Panels[8].Text:= IntToStr(ALTO) + 'x' + IntToStr(ANCHO);
    SetLength(MAT,ALTO,ANCHO,3);
    copBM(ALTO,ANCHO,MAT,BMAP);
    Image1.Picture.Assign(BMAP); //Visualizar imagen.

    //Se grafica el histograma de la imagen.
    grafHist();
    //Habilita las opciones del menú.
    MenuItem3.Enabled := True;
    MenuItem6.Enabled := True;
    MenuItem9.Enabled := False;
    MenuItem2.Enabled := True; //Habilita conversión a HSV
    //Si la imagen es de NxN, se habilita la binarización.
    If ANCHO = ALTO then
      MenuItem11.Enabled := True
    else
      MenuItem11.Enabled := False;
  end;
end;

//Aplicación de filtro negativo.
procedure TForm1.MenuItem5Click(Sender: TObject);
var
  i,j     :  Integer;
  k       :  Byte;
begin
  for i:=0 to ALTO-1 do
  begin
    for j:=0 to ANCHO-1 do
    begin
      for k:=0 to 2 do
      begin
        MAT[i,j,k]:=255-MAT[i,j,k];
      end; //k
    end; //j
  end; //i

  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT,BMAP);

  //Visualizar el resultado en pantalla.
  Image1.Picture.Assign(BMAP);
  //Se actualiza el histograma de la imagen.
  grafHist();
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin

end;

//Conversión a escala de grises.
procedure TForm1.MenuItem7Click(Sender: TObject);
begin
  //Se llama a la función que transforma la imagen a escala de grises.
  toGray();
  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT,BMAP);

  //Visualizar el resultado en pantalla.
  Image1.Picture.Assign(BMAP);

  //Se actualiza el histograma de la imagen.
  grafHist();
end;

//Aplicación de filtro logaritmo natural.
procedure TForm1.MenuItem8Click(Sender: TObject);
var
  i,j     :  Integer;
  k       :  Byte;
  valor   :  real;
begin
   for i:=0 to ALTO-1 do
   begin
    for j:=0 to ANCHO-1 do
    begin
      for k:=0 to 2 do
      begin
        valor := (ln(MAT[i,j,k] + 1))/(ln(255 + 1)) * 255;
        MAT[i,j,k]:= round(valor);
      end;
    end; //j
   end; //i

  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT,BMAP);

  //Visualizar el resultado en pantalla.
  Image1.Picture.Assign(BMAP);
  //Se actualiza el histograma de la imagen.
  grafHist();
end;

//Conversión de HSV a RGB.
procedure TForm1.MenuItem9Click(Sender: TObject);
var
  i,j     :  Integer;
  C, X, m     : Real;
  R,G,B       : Real;
  H,S,V       : Real;
begin
  for i:=0 to ALTO-1 do
  begin
    for j:=0 to ANCHO-1 do
    begin
      //Se convierten los valores HSV a su escala (0-1 y 0-360).
      V := MAT[i,j,0]/255;
      S := MAT[i,j,1]/255;
      H := MAT[i,j,2]*2;

      C := V * S;
      X := C *(1 - abs((H / 60) mod 2 - 1));
      m := V - C;

      //Calcula los valores RGB.
      If H < 60 then
      begin
        R := C;
        G := X;
        B := 0;
      end
      else If H < 120 then
      begin
        R := X;
        G := C;
        B := 0;
      end
      else If H < 180 then
      begin
        R := 0;
        G := C;
        B := X;
      end
      else If H < 240 then
      begin
        R := 0;
        G := X;
        B := C;
      end
      else If H < 300 then
      begin
        R := X;
        G := 0;
        B := C;
      end
      else If H < 360 then
      begin
        R := C;
        G := 0;
        B := X;
      end;

      //Se escalan los valores RGB y se asignan a la imagen.
      MAT[i,j,0] := Round((R + m) * 255);
      MAT[i,j,1] := Round((G + m) * 255);
      MAT[i,j,2] := Round((B + m) * 255);
    end; //j
  end; //i

  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT,BMAP);
  //Visualizar el resultado en pantalla.
  Image1.Picture.Assign(BMAP);
  //Se actualiza el histograma de la imagen.
  grafHist();
  //Deshabilita conversión a RGB. Habilita conversión a HSV.
  MenuItem2.Enabled := True;
  MenuItem9.Enabled := False;
end;

procedure TForm1.RChannelCustomDrawPointer(ASender: TChartSeries;
  ADrawer: IChartDrawer; AIndex: Integer; ACenter: TPoint);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //Crear el objeto BMAP.
  BMAP:=TBitmap.Create;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  //Al mover el mouse, se indican las coordenadas X Y.
  StatusBar1.Panels[1].Text:= IntToStr(X);
  StatusBar1.Panels[2].Text:= IntToStr(Y);
  StatusBar1.Panels[4].Text:= IntToStr(MAT[y,x,0]);
  StatusBar1.Panels[5].Text:= IntToStr(MAT[y,x,1]);
  StatusBar1.Panels[6].Text:= IntToStr(MAT[y,x,2]);
end;

//Procedimiento que pide parámetro r y aplica binarización dinámica.
procedure TForm1.MenuItem11Click(Sender: TObject);
var
  r  :  Integer;
begin
  r := 3;
  //Abre ventana para seleccionar r.
  Form2.setParameters(ANCHO, ALTO);
  Form2.Showmodal;
  //En caso de haber seleccionado un valor r.
  if form2.ModalResult = MROk then
  begin
    r := Form2.TrackBar1.Position;
    binarizar(r);
  end;
end;

//Aplicación del filtro Gamma.
procedure TForm1.MenuItem12Click(Sender: TObject);
var
  gamma : Float;
  i,j   : Integer;
  k     : Byte;
begin
  gamma := 1;
  //Abre ventana para seleccionar gamma.
  Form3.init();
  Form3.Showmodal;
  //En caso de haber seleccionado un valor gamma.
  if Form3.ModalResult = MROk then
  begin
    gamma := Form3.FloatSpinEdit1.Value;
    for i:=0 to ALTO-1 do
    begin
      for j:=0 to ANCHO-1 do
      begin
        for k:=0 to 2 do
        begin
          MAT[i,j,k]:= round(power(MAT[i,j,k]/255, gamma) * 255);
        end; //k
      end; //j
    end; //i

    //Se copia el resultado de la matriz al bitmap.
    copMB(ALTO,ANCHO,MAT,BMAP);

    //Visualizar el resultado en pantalla.
    Image1.Picture.Assign(BMAP);
    //Se actualiza el histograma de la imagen.
    grafHist();
  end;
end;

//Copiar el contenido de la imagen a una Matriz.
procedure Tform1.copiaIM(al,an: Integer; var M:MATRGB);
var
  i,j  : Integer;
  cl   : Tcolor;
begin
  for i :=0 to al-1 do
  begin
    for j:=0 to an-1 do
    begin
      //Leer valor total de color del pixel j,i.
      cl:=Image1.Canvas.Pixels[j,i];
      MAT[i,j,0]:=GetRValue(cl);
      MAT[i,j,1]:=GetGValue(cl);
      MAT[i,j,2]:=GetBValue(cl);
    end; //j
  end;//i
end;


//Copiar de Bitmap a Matriz.
procedure Tform1.copBM(al,an:Integer; var M:MATRGB; B:Tbitmap);
var
  i,j,k : Integer;
  P     :Pbyte;
begin
  for i:=0 to al-1 do
  begin
    B.BeginUpdate;
    //Leer RGB de todo el renglon-i.
    P:=B.ScanLine[i];
    B.EndUpdate;

    for j:=0 to an-1 do
    begin
       k:=3*j;
       MAT[i,j,0]:=P[k+2];
       MAT[i,j,1]:=P[k+1];
       MAT[i,j,2]:=P[k];
    end; //j
  end; //i
end;

//Procedimiento para copiar de Matriz a bitmap.
procedure tform1.copMB(al,an: Integer; M:MATRGB; var B:Tbitmap);
var
  i,j,k : Integer;
  P     :Pbyte;
begin
  for i:=0 to al-1 do
  begin
    B.BeginUpdate;
    //Invocar método para tener listo en memoria la localidad a modificar--> toda la fila.
    P:=B.ScanLine[i];
    B.EndUpdate;

    for j:=0 to an-1 do
    //Asignando valores de matriz al apuntador scanline--> Bitmap.
    begin
       k:=3*j;
       P[k+2]:=MAT[i,j,0];
       P[k+1]:=MAT[i,j,1];
       P[k]:=MAT[i,j,2];
    end; //j
  end; //i
end;

//Graficar histograma de la imagen.
procedure tform1.grafHist();
type
  //Matriz que guardará la frecuencia de cada valor entre 0 y 255 por canal.
  matFrecRGB = array[0..3] of array[0..255] of Integer;
var
  i,j, nPixels :  Integer;
  k,val   :  Byte;
  matHist : matFrecRGB;
begin
  //Limpieza de series antes graficar.
  RChannel.clear;
  GChannel.clear;
  BChannel.clear;
  //Se inicializan las frecuencias en 0.
  for k:=0 to 2 do
  begin
    for val:=0 to 255 do
    begin
       matHist[k,val] := 0;
    end;
  end;
  //Se inicializa el número de píxeles.
  npixels := ANCHO * ALTO;
  //Se establecen los títulos de las series.
  RChannel.title := 'R';
  GChannel.title := 'G';
  BChannel.title := 'B';

  //Se calculan las frecuencias en los 3 canales.
  for i:=0 to ALTO-1 do
  begin
    for j:=0 to ANCHO-1 do
    begin
      for k:=0 to 2 do
      begin
        //Incremento del valor MAT[i,j,k] del canal k.
        Inc(matHist[k, MAT[i,j,k]]);
      end; //k
    end; //j
  end; //i

  //Graficación de histograma para cada canal.
  for i:=0 to 255 do
  begin
    //Se grafica Rojo para el valor i.
    RChannel.AddXY(i, matHist[0,i]/nPixels*100);
    //Se grafica Verde para el valor i.
    GChannel.AddXY(i, matHist[1,i]/nPixels*100);
    //Se grafica Azul para el valor i.
    BChannel.AddXY(i, matHist[2,i]/nPixels*100);
  end;
end;

//Convierte la imagen a escala de grises.
procedure tform1.toGray();
var
  i,j     :  Integer;
  k       :  Byte;
  mean    :  integer;
begin
  for i:=0 to ALTO-1 do
  begin
    for j:=0 to ANCHO-1 do
    begin
      //Se obtiene promedio de los 3 canales.
      mean := 0;
      mean := (MAT[i,j,0] + MAT[i,j,1] + MAT[i,j,2]) div 3;
      for k:=0 to 2 do
      begin
        MAT[i,j,k]:= mean;
      end; //k
    end; //j
  end; //i
end;

//Aplica binarización dinámica a la imagen.
procedure tform1.binarizar(r: Integer);
var
  i,j,regx,regy :  Integer;
  mean    :  integer;
  //Variables que definen el número de regiones de r píxeles a lo ancho y alto.
  regionesAn, regionesAl :  integer;
  //Variables que indican el límite de cada región a lo ancho y alto.
  limitRegX, limitRegY   : integer;
  //Variables que guardan el ancho sobrante y alto sobrante después de la binarización de regiones rxr.
  anchoSobrante, altoSobrante : integer;
  //Variables que guardan la posición del último píxel de la binarización de regiones rxr (esq. inf. derecha).
  lastPixelX, lastPixelY : integer;
begin
  //Conversión a escala de grises.
  toGray();
  //********************************** Binarización de regiones rxr **********************************
  //Se calcula el número de regiones de r píxeles a lo ancho y lo alto.
  regionesAn := trunc(ANCHO / r);
  regionesAl := trunc(ALTO / r);
  //Aplicamos la binarización en la región regy,regx de rxr píxeles.
  for regy:=0 to regionesAl-1 do
  begin
    for regx:=0 to regionesAn-1 do
    begin
      //Se determina límite regional en lo alto.
      limitRegY := (regy+1)*r - 1;
      //Se obtiene la suma de las intensidades de los píxeles en la región.
      mean := 0;
      for i:=regy*r to limitRegY do
      begin
        //Se determina límite regional en el ancho.
        limitRegX := (regx+1)*r - 1;
        for j:=regx*r to limitRegX do
        begin
          mean := mean + MAT[i,j,0];
        end; //i
      end; //j

      //Se obtiene el promedio de las intensidades.
      mean := round(mean /(r*r));

      //Se aplica la binarización a cada píxel de la región.
      for i:=regy*r to limitRegY do
      begin
        //Se determina límite regional en el ancho.
        limitRegX := (regx+1)*r - 1;
        for j:=regx*r to limitRegX do
        begin
          //El valor es menor al umbral.
          If MAT[i,j,0] < mean then
          begin
            MAT[i,j,0] := 0;
            MAT[i,j,1] := 0;
            MAT[i,j,2] := 0;
          end
          //El valor es mayor o igual al umbral.
          else
          begin
            MAT[i,j,0] := 255;
            MAT[i,j,1] := 255;
            MAT[i,j,2] := 255;
          end;
        end; //j
      end; //i
    end; //regx
  end; //regy

  //Se guarda la posición del último píxel binarizado.
  lastPixelX := limitRegX;
  lastPixelY := limitRegY;
  //Calcula píxeles sobrantes a lo ancho y en lo alto.
  anchoSobrante := ANCHO - lastPixelX - 1;
  altoSobrante := ALTO - lastPixelY - 1;

  //********************************** Binarización de píxeles sobrantes a lo ancho **********************************
  //Verifica que existan píxeles sobrantes a lo ancho.
  if anchoSobrante > 0 then
  begin
    //El alto se dividirá en 3 regiones de r píxeles.
    r := trunc(ALTO / 3);
    //Aplicamos la binarización a las 3 regiones.
    for regy:=0 to 2 do
    begin
      //Se determina límite regional en lo alto.
      //Si es la última región, entonces se tomarán los píxeles que resten del alto.
      if regy = 2 then
        limitRegY := ALTO-1
      else
        limitRegY := (regy+1)*r - 1;

      //Se obtiene la suma de las intensidades de los píxeles en la región.
      mean := 0;
      for i:=regy*r to limitRegY do
      begin
        for j:=lastPixelX to ANCHO-1 do
        begin
          mean := mean + MAT[i,j,0];
        end; //i
      end; //j

      //Se obtiene el promedio de las intensidades.
      mean := round(mean / (((limitRegY - regy*r) + 1) * anchoSobrante));

      //Se aplica la binarización a cada píxel de la región.
      for i:=regy*r to limitRegY do
      begin
        for j:= lastPixelX to ANCHO-1 do
        begin
          //El valor es menor al umbral.
          If MAT[i,j,0] < mean then
          begin
            MAT[i,j,0] := 0;
            MAT[i,j,1] := 0;
            MAT[i,j,2] := 0;
          end
          //El valor es mayor o igual al umbral.
          else
          begin
            MAT[i,j,0] := 255;
            MAT[i,j,1] := 255;
            MAT[i,j,2] := 255;
          end;
        end; //j
      end; //i
    end; //regy
  end; //if

  //********************************** Binarización de píxeles sobrantes en lo alto **********************************
  //Verifica que existan píxeles sobrantes en lo alto.
  if altoSobrante > 0 then
  begin
    //El ancho (hasta el último píxel binarizado rxr) se dividirá en 3 regiones de r píxeles.
    r := trunc(lastPixelX / 3);
    //Aplicamos la binarización a las 3 regiones.
    for regx:=0 to 2 do
    begin
      //Se determina límite regional en lo ancho.
      //Si es la última región, entonces se tomarán los píxeles que resten del ancho.
      if regx = 2 then
        limitRegX := lastPixelX-1
      else
        limitRegX := (regx+1)*r - 1;

      //Se obtiene la suma de las intensidades de los píxeles en la región.
      mean := 0;
      for i:=lastPixelY to ALTO-1 do
      begin
        for j:=regx*r to limitRegX do
        begin
          mean := mean + MAT[i,j,0];
        end; //i
      end; //j

      //Se obtiene el promedio de las intensidades.
      mean := round(mean / (((limitRegX - regx*r) + 1) * altoSobrante));

      //Se aplica la binarización a cada píxel de la región.
      for i:=lastPixelY to ALTO-1 do
      begin
        for j:=regx*r to limitRegX do
        begin
          //El valor es menor al umbral.
          If MAT[i,j,0] < mean then
          begin
            MAT[i,j,0] := 0;
            MAT[i,j,1] := 0;
            MAT[i,j,2] := 0;
          end
          //El valor es mayor o igual al umbral.
          else
          begin
            MAT[i,j,0] := 255;
            MAT[i,j,1] := 255;
            MAT[i,j,2] := 255;
          end;
        end; //j
      end; //i
    end; //regx
  end; //if

  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT,BMAP);
  //Visualizar el resultado en pantalla.
  Image1.Picture.Assign(BMAP);
  //Se actualiza el histograma de la imagen.
  grafHist();
end;

end.
