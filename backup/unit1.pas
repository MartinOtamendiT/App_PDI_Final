unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus, Unit2,
  Unit3, Unit4, Unit5, ExtDlgs, LCLIntf, ComCtrls, StdCtrls, ColorBox, TAGraph,
  TASeries, math, TADrawUtils, TACustomSeries, LazLogger;

type



  { TForm1 }
  //Matriz Tri-dimensional para almacenar contenido de imagen.
  MATRGB = Array of Array of Array of Byte;
  //Matriz que guardará la frecuencia de cada valor entre 0 y 255 por canal.
  matFrecRGB = Array[0..3] of Array[0..255] of Integer;
  //Matriz que guardará números complejos (parte real en 0, parte imaginaria en 1).
  complexMAT = array of array of array[0..1] of Real;

  TForm1 = class(TForm)
    Chart1: TChart;
    ColorDialog1: TColorDialog;
    GChannel: TLineSeries;
    BChannel: TLineSeries;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem30: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem32: TMenuItem;
    ProgressBar1: TProgressBar;
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
    SavePictureDialog1: TSavePictureDialog;
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    StatusBar1: TStatusBar;
    procedure Chart1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Chart1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Chart1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Label2Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem13Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure MenuItem15Click(Sender: TObject);
    procedure MenuItem16Click(Sender: TObject);
    procedure MenuItem18Click(Sender: TObject);
    procedure MenuItem19Click(Sender: TObject);
    procedure MenuItem20Click(Sender: TObject);
    procedure MenuItem21Click(Sender: TObject);
    procedure MenuItem23Click(Sender: TObject);
    procedure MenuItem24Click(Sender: TObject);
    procedure MenuItem25Click(Sender: TObject);
    procedure MenuItem26Click(Sender: TObject);
    procedure MenuItem27Click(Sender: TObject);
    procedure MenuItem28Click(Sender: TObject);
    procedure MenuItem29Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem30Click(Sender: TObject);
    procedure MenuItem31Click(Sender: TObject);
    procedure MenuItem32Click(Sender: TObject);
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
    //Copiar de Matriz a Matriz.
    procedure copMtoM(al,an:Integer; var MOrigin:MATRGB; var MCopy:MATRGB);
    //Intercambia los puntos de origen y fin de la selección.
    procedure exchangeStartEnd();
    //Graficar histograma de la imagen.
    procedure grafHist();
    //Convierte la imagen a escala de grises.
    procedure toGray();
    //Aplica binarización dinámica a la imagen.
    procedure binarizar(r: Integer);
    //Rota la imagen 90° o -90°.
    procedure rotarImagen(direction: Boolean);
    //Permite que el usuario seleccione 4 colores y calcula la paleta correspondiente con interpolación lineal.
    procedure generarPaletaColores();
    //Función que calcula la transformada de Fourier
    procedure calcTFourier(var FOURIERMAT: complexMAT);
  end;

//Variables globales.
var
  Form1: TForm1;
  //Variables para selección en imagen.
  StartPoint, EndPoint: TPoint;
  selectionFlag: Boolean;
  imgSelectionEnabled: Boolean;
  //Variables para selección en Histograma.
  StartHist, EndHist: TPoint;
  selectionFlagHist: Boolean;
  //Dimensiones de la imagen.
  ALTO, ANCHO   : Integer;
  ALTO_origin, ANCHO_origin : Integer;
  //Matrices de la imagen.
  MAT           : MATRGB;
  MATOrigin     : MATRGB;
  MAT2AUX  : MATRGB;
  //Matriz de frecuencias para el histograma.
  matHist : matFrecRGB;
  //Objeto orientado a directivas/metodos para .BMP.
  BMAP          :Tbitmap;
  BMAPAUX       :Tbitmap;
  //Matriz de colores calculados con interpolación lineal.
  paleta: Array[0..255] of Array[0..2] of Byte;

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
  exchangeStartEnd();
  for i:=StartPoint.Y to EndPoint.Y do
  begin
    for j:=StartPoint.X to EndPoint.X do
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
end;

//Función que calcula la transformada de Fourier de la imagen.
procedure TForm1.calcTFourier(var FOURIERMAT: complexMAT);
var
  i,j, u,v, uTranslated, vTranslated: Integer;
  realVal, imVal:  Real;
  phiu, phiv : Real;
  cosw, senw : Real;
  s : Real;
begin
  //Calcula factor escalar común.
  s := 1/sqrt(ANCHO * ALTO);
  //Recorre toda la imagen y calcula la transformada de Fourier de la imagen.
  for u:=0 to ALTO-1 do
  begin
    for v:=0 to ANCHO-1 do
    begin
      //Inicializa las sumas de ambas partes en 0.
      realVal := 0;
      imVal := 0;
      //Realiza translación de u y v al plano de Fourier.
      uTranslated := u - floor(ALTO/2) ;
      vTranslated := v - floor(ANCHO/2);
      //Calcula factores comunes.
      phiu := 2 * Pi * uTranslated/ALTO ;
      phiv := 2 * Pi * vTranslated/ANCHO;
      //Aquí se calcula la transformada.
      for i:=0 to ALTO-1 do
        for j:=0 to ANCHO-1 do
        begin
          //Calcula valores de seno y coseno.
          cosw := cos(phiu*i + phiv*j);
          senw := sin(phiu*i + phiv*j);
          //Calcula partes real e imaginaria de la transformada y los agrega a la suma correspondiente.
          realVal := realVal + MAT[i,j,0] * cosw + MAT[i,j,0] * senw;
          imVal := imVal + MAT[i,j,0] * cosw - MAT[i,j,0] * senw;
        end;//j
      //Guarda valores multiplicados por el factor escalar común.
      FOURIERMAT[u,v,0] := realVal * s;
      FOURIERMAT[u,v,1] := imVal * s;
    end;//v
    ProgressBar1.StepIt;
  end;//u
end;

//Implementa la transformada de Fourier y permite visualizar el espectro.
procedure TForm1.MenuItem30Click(Sender: TObject);
var
  FOURIERMAT : complexMAT;
  FOURIERMAGS : Array of Array of Real;
  ESPECMAT : MATRGB;
  i,j, u,v : Integer;
  magnitudMax :  Real;
  k : Byte;
begin
  //Conversión a escala de grises.
  toGray();
  SetLength(FOURIERMAT,ALTO,ANCHO);//Valores de la transformada de Fourier.
  SetLength(FOURIERMAGS,ALTO,ANCHO);//Magnitudes de la transformada.
  SetLength(ESPECMAT,ALTO,ANCHO,3); //Espectro.

  ProgressBar1.Position := 0;
  ProgressBar1.Max := ALTO*3;
  ProgressBar1.Step:= round(ProgressBar1.Width / (ALTO));
  //Calcula la transformada de Fourier de la imagen.
  calcTFourier(FOURIERMAT);

  //Calcula la magnitud de los valores resultantes de la transformada para cada píxel.
  magnitudMax := 0;
  for u:=0 to ALTO-1 do
  begin
    for v:=0 to ANCHO-1 do
    begin
      FOURIERMAGS[u,v] := sqrt(sqr(FOURIERMAT[u,v,0]) + sqr(FOURIERMAT[u,v,1]));
      //Busca la magnitud máxima en la imagen.
      If FOURIERMAGS[u,v] > magnitudMax then
        magnitudMax := FOURIERMAGS[u,v];
    end;
    ProgressBar1.StepIt;
  end;

  //Normaliza los valores de las magnitudes.
  for u:=0 to ALTO-1 do
  begin
    for v:=0 to ANCHO-1 do
    begin
      FOURIERMAGS[u,v] := 255/ln(1 + magnitudMax)*ln(1 + abs(FOURIERMAGS[u,v]));
    end;//v
    ProgressBar1.StepIt;
  end;//u

  //Guarda magnitudes en la matriz del espectro.
  for i:=0 to ALTO-1 do
    for j:=0 to ANCHO-1 do
      for k:=0 to 2 do
        ESPECMAT[i,j,k] := round(FOURIERMAGS[i,j]);

  //Se copia el resultado en la matriz de la imagen.
  copMtoM(ALTO, ANCHO, ESPECMAT, MAT2AUX);
  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT2AUX,BMAPAUX);
  //Se muestra el resultado del espectro en TImage2.
  Image2.Picture.Assign(BMAPAUX);
end;

//Aplica filtro Pasa alta Gaussiano a la imagen.
procedure TForm1.MenuItem31Click(Sender: TObject);
var
  FOURIERMAT : complexMAT;
  FOURIERINVMAT : complexMAT;
  i,j, u,v: Integer;
  D, H:  Real;
  k : Byte;
  realVal, imVal:  Real;
  phiu, phiv : Real;
  cosw, senw : Real;
  s: Real;
  magnitudMax, magnitudMin:  Real;
begin
  //Conversión a escala de grises.
  toGray();
  SetLength(FOURIERMAT,ALTO,ANCHO);//Valores de la transformada de Fourier.
  SetLength(FOURIERINVMAT,ALTO,ANCHO);//Valores de la transformada inversa.

  //Configura barra de progreso.
  ProgressBar1.Position := 0;
  ProgressBar1.Max := ALTO*4;
  ProgressBar1.Step:= round(ProgressBar1.Width / (ALTO));
  //Calcula la transformada de Fourier de la imagen.
  calcTFourier(FOURIERMAT);

  //Calcula factor escalar común.
  s := 1/sqrt(ANCHO * ALTO);
  //Recorre toda la imagen, aplica filtro Gaussiano y calcula la transformada Inversa de Fourier de la imagen.
  for i:=0 to ALTO-1 do
  begin
    for j:=0 to ANCHO-1 do
    begin
      //Inicializa las sumas de ambas partes en 0.
      realVal := 0;
      imVal := 0;
      //Calcula factores comunes.
      phiu := 2 * Pi * i/ALTO ;
      phiv := 2 * Pi * j/ANCHO;
      //Aquí se aplica el filtro y se calcula la transformada inversa.
      for u:=0 to ALTO-1 do
        for v:=0 to ANCHO-1 do
        begin
          //Calcula distancia del píxel al centro.
          D := sqrt(sqr(u - ALTO/2) + sqr(v - ANCHO/2));
          //Calcula valor del filtro Gaussiano.
          H := 1-exp(-sqr(D)/(2*sqr(60)));

          //Calcula valores de seno y coseno.
          cosw := cos(phiu*u + phiv*v);
          senw := -sin(phiu*u + phiv*v);
          //Calcula partes real e imaginaria de la transformada y los agrega a la suma correspondiente.
          realVal := realVal + (H * (FOURIERMAT[u,v,0] * cosw + FOURIERMAT[u,v,0] * senw));
          imVal := imVal + (H * (FOURIERMAT[u,v,1] * cosw - FOURIERMAT[u,v,1] * senw));
        end;//v
      //Guarda valores multiplicados por el factor escalar común.
      FOURIERINVMAT[i,j,0] := realVal * s;
      FOURIERINVMAT[i,j,1] := imVal * s;
    end;//j
    ProgressBar1.StepIt;
  end;//i

  //Se copia el resultado del filtro en la matriz auxiliar y calcula valores máximo y mínimo.
  magnitudMax := 0;
  magnitudMin := MAT2AUX[0,0,0];
  for i:=0 to ALTO-1 do
  begin
    for j:=0 to ANCHO-1 do
    begin
      for k:=0 to 2 do
        MAT2AUX[i,j,k] := round(abs(FOURIERINVMAT[ALTO-i-1,ANCHO-j-1,0]+FOURIERINVMAT[ALTO-i-1,ANCHO-j-1,1]));
      //Busca la magnitud máxima en la imagen.
      If MAT2AUX[i,j,0] > magnitudMax then
        magnitudMax := MAT2AUX[i,j,0];
      //Busca la magnitud mínima en la imagen.
      If MAT2AUX[i,j,0] < magnitudMin then
        magnitudMin := MAT2AUX[i,j,0];
    end;
    ProgressBar1.StepIt;
  end;

  //Aplica normalización min-max.
  for i:=0 to ALTO-1 do
  begin
    for j:=0 to ANCHO-1 do
      for k:=0 to 2 do
        MAT2AUX[i,j,k] := round((MAT2AUX[i,j,k] - magnitudMin)/(magnitudMax - magnitudMin) * 255);
    ProgressBar1.StepIt;
  end;

  //Se copia el resultado del filtro de Fourier en la imagen.
  copMtoM(ALTO, ANCHO, MAT2AUX, MAT);
  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT,BMAP);
  copMB(ALTO,ANCHO,MAT2AUX,BMAPAUX);
  //Se muestra el resultado del filtro en la imagen y en TImage2.
  Image1.Picture.Assign(BMAP);
  Image2.Picture.Assign(BMAPAUX);
  //Se actualiza el histograma de la imagen.
  grafHist();
end;

//Aplica filtro morfológico de dilatación para imágenes con fondo negro.
//Cómo efecto secundario, erosiona en imágenes con fondo blanco.
procedure TForm1.MenuItem32Click(Sender: TObject);
var
  MORFOMAT : MATRGB;
  i,j, x,y : Integer;
  //Bandera que indicará si al menos un píxel del elemento estructura coincide con alguno en la región de la imagen.
  matchFlag: Boolean;
  elementEstructura: Array[0..2, 0..2] of Integer =
  ((0, 255, 0),
  (0, 255, 0),
  (0, 255, 0));
begin
  //Aplica binarización a la imagen en caso de NO ser binaria.
  //StartPoint := Point(0,0);
  //EndPoint := Point(ANCHO-1, ALTO-1);
  //binarizar(min(ALTO,ANCHO));
  //Se copia matriz original a la del resultado del filtro.
  SetLength(MORFOMAT,ALTO,ANCHO,3);
  copMtoM(ALTO, ANCHO, MAT, MORFOMAT);

  //Se recorre toda la imagen.
  for i := 1 to ALTO-2 do
    for j := 1 to ANCHO-2 do
    begin
      matchFlag := False;
      y := -1;
      //Recorrido en la matriz del elemento estructura.
      while (matchFlag = False) AND  (y<=1) do
      begin
        x := -1;
        while (matchFlag = False) AND  (x<=1) do
        begin
          //El píxel en la imagen y el píxel en el elemento estructura coinciden.
          if (MAT2AUX[y+i, x+j,0] = elementEstructura[y+1,x+1]) AND (elementEstructura[y+1,x+1] = 255) then
          begin
            MORFOMAT[i,j,0] := 255;
            MORFOMAT[i,j,1] := 255;
            MORFOMAT[i,j,2] := 255;
            //Indica que se ha encontrado una coincidencia para terminar de buscar en la región.
            matchFlag := True;
          end;
          x := x + 1;
        end; //x
        y := y + 1;
      end; //y
    end; //j

  //Se copia el resultado en la matriz de la imagen.
  copMtoM(ALTO, ANCHO, MORFOMAT, MAT2AUX);
  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT2AUX,BMAPAUX);
  //Visualizar el resultado en pantalla.
  Image2.Picture.Assign(BMAPAUX);
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
end;

//Se abre imagen con ScanLine.
procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  if OpenPictureDialog1.execute  then
  begin
    Image1.Enabled := True;
    BMAP.LoadFromFile(OpenPictureDialog1.FileName);
    ALTO := BMAP.Height;
    ANCHO := BMAP.Width;
    //Realiza una copia de las dimensiones originales para restauración.
    ALTO_origin := BMAP.Height;
    ANCHO_origin := BMAP.Width;

    //Se garantizan los 8 bits por canal.
    if BMAP.PixelFormat<> pf24bit then
    begin
      BMAP.PixelFormat:=pf24bit;
    end;

    //Se copian las propiedades del BMAP origen al BMAP auxiliar.
    BMAPAUX := Tbitmap.Create;
    BMAPAUX.Assign(BMAP);

    StatusBar1.Panels[8].Text:= IntToStr(ALTO) + 'x' + IntToStr(ANCHO);
    SetLength(MAT,ALTO,ANCHO,3);
    SetLength(MATOrigin,ALTO,ANCHO,3);
    SetLength(MAT2AUX,ALTO,ANCHO,3);
    copBM(ALTO, ANCHO, MAT, BMAP);
    copMtoM(ALTO, ANCHO, MAT, MATOrigin); //Se guarda una copia del edo. original de la matriz.
    copMtoM(ALTO, ANCHO, MAT, MAT2AUX); //Se guarda una copia para el auxiliar de la imagen.
    Image1.Picture.Assign(BMAP); //Visualizar imagen.
    Image2.Picture.Assign(BMAP); //Visualizar imagen.

    //Inicializa la selección para toda la imagen.
    StartPoint := Point(0,0);
    EndPoint := Point(ANCHO-1, ALTO-1);
    //Desactiva la selección rectangular en la imagen.
    imgSelectionEnabled := False;

    //Se grafica el histograma de la imagen.
    Chart1.Enabled := True;
    grafHist();
    //Inicializa puntos de selección del histograma.
    StartHist := Point(0, 10);
    EndHist := Point(255, 10);
    Label2.Caption := 'Rango seleccionado: ' + IntToStr(StartHist.X) + ' - ' + IntToStr(EndHist.X);

    //Habilita las opciones del menú.
    MenuItem3.Enabled := True; //Habilita menú de Filtros.
    MenuItem6.Enabled := True; //Habilita menú de Conversión de modelo.
    MenuItem14.Enabled := True; //Habilita opción Restaurar.
    MenuItem15.Enabled := True; //Habilita opción Guardar como.
    MenuItem17.Enabled := True; //Habilita opción de Selección.
    MenuItem10.Enabled := True; //Habilita opción de Operaciones.
    MenuItem22.Enabled := True; //Habilita opción de Imagen.
  end;
end;

//Aplicación de filtro negativo.
procedure TForm1.MenuItem5Click(Sender: TObject);
var
  i,j     :  Integer;
  k       :  Byte;
begin
  exchangeStartEnd();
  for i:=StartPoint.Y to EndPoint.Y do
  begin
    for j:=StartPoint.X to EndPoint.X do
    begin
      for k:=0 to 2 do
      begin
        MAT[i,j,k]:=255-MAT[i,j,k];
      end; //k
    end; //j
  end; //i

  //Se guarda una copia en la matriz auxiliar.
  copMtoM(ALTO, ANCHO, MAT, MAT2AUX);
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
  //Se guarda una copia en la matriz auxiliar.
  copMtoM(ALTO, ANCHO, MAT, MAT2AUX);
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
  exchangeStartEnd();
  for i:=StartPoint.Y to EndPoint.Y do
  begin
    for j:=StartPoint.X to EndPoint.X do
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
  exchangeStartEnd();
  for i:=StartPoint.Y to EndPoint.Y do
  begin
    for j:=StartPoint.X to EndPoint.X do
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
end;

procedure TForm1.RChannelCustomDrawPointer(ASender: TChartSeries;
  ADrawer: IChartDrawer; AIndex: Integer; ACenter: TPoint);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //Crear el objeto BMAP.
  BMAP := TBitmap.Create;
  //La selección en la imagen no es permitida.
  selectionFlag := False;
  imgSelectionEnabled := False;
  //La selección en el histograma no es permitida.
  selectionFlagHist := False;
end;

//Actualiza la posición del mouse al moverse en el histograma.
procedure TForm1.Chart1MouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
begin
  if ((X >= 0) AND (X <= 255)) then
  begin
    Label1.Caption := 'Valor X: ' + IntToStr(X);
    //Color y tamaño de la pluma.
    Chart1.Canvas.Pen.Color := RGBToColor(94, 246, 255);
    Chart1.Canvas.Pen.Width := 5;

    //Detecta si se está presionado el botón izquierdo del mouse.
    if selectionFlagHist then
    begin
      with Chart1.Canvas do begin
        //Realiza un primer trazo de la línea.
        Pen.mode := pmXor;
        MoveTo(StartHist);
        LineTo(EndHist);
        //Traza la línea a la par que se mueve el mouse.
        Pen.mode := pmXor;
        MoveTo(StartHist);
        LineTo(X, Y);
      end;
      //Se asegura de registrar el punto final de la selección.
      EndHist := Point(X, Y);
    end;
  end;
end;

//Se activa al soltar el botón del mouse en el histograma.
procedure TForm1.Chart1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //Termina la selección al dejar de presionar el botón izquierdo.
  if Button = mbLeft then
  begin
    with Chart1.Canvas do begin
      //Asegura que la línea de selección quede marcada en la imagen.
      Pen.Color := RGBToColor(0, 206, 189);
      Pen.mode := pmCopy;
      MoveTo(StartHist);
      LineTo(EndHist);
    end;
    //Se desactiva la bandera de selección.
    selectionFlagHist := False;
    Label2.Caption := 'Rango seleccionado: ' + IntToStr(StartHist.X) + ' - ' + IntToStr(EndHist.X);
  end;

  //Los cambios de deselección se aplican al dejar de presionar el botón derecho.
  if Button = mbRight then
  begin
    grafHist();
  end;
end;

//Se activa al presionar el botón del mouse en el histograma.
procedure TForm1.Chart1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //Comienza la selección al presionar el botón izquierdo.
  if Button = mbLeft then
  begin
    //Se activa la bandera de selección.
    selectionFlagHist := True;
    //Limpia la última selección hecha.
    grafHist();
    //Se inicia la selección en el punto del click.
    StartHist := Point(X, Y);
    EndHist := Point(X, Y);
  end;

  //Cancela la selección al presionar el botón derecho.
  if Button = mbRight then
  begin
    selectionFlagHist := False;
    grafHist();
  end;
end;

//*********************************************************************************************************
//Se activa al presionar el botón del mouse en la imagen.
procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //Comienza la selección al presionar el botón izquierdo.
  if ((Button = mbLeft) AND imgSelectionEnabled) then
  begin
    //Se activa la bandera de selección.
    selectionFlag := True;
    //Limpia la última selección hecha.
    copMB(ALTO,ANCHO,MAT,BMAP);
    Image1.Picture.Assign(BMAP);
    //Se inicia la selección en el punto del click.
    StartPoint := Point(X, Y);
    EndPoint := Point(X, Y);
    //Color y tamaño de la pluma.
    Image1.Canvas.Pen.Color := clWhite;
    Image1.Canvas.Pen.Width := 2;
  end;

  //Cancela la selección al presionar el botón derecho.
  if Button = mbRight then
  begin
    selectionFlag := False;
    copMB(ALTO,ANCHO,MAT,BMAP);
    Image1.Picture.Assign(BMAP);
  end;
end;

//Actualiza la posición del mouse al moverse en la imagen.
procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  //Al mover el mouse, se indican las coordenadas X,Y y los valores RGB.
  if ((X >= 0) AND (X < ANCHO)) AND ((Y >= 0) AND (Y < ALTO)) then
  begin
    StatusBar1.Panels[1].Text:= IntToStr(X);
    StatusBar1.Panels[2].Text:= IntToStr(Y);
    StatusBar1.Panels[4].Text:= IntToStr(MAT[y,x,0]);
    StatusBar1.Panels[5].Text:= IntToStr(MAT[y,x,1]);
    StatusBar1.Panels[6].Text:= IntToStr(MAT[y,x,2]);

    //Detecta si se está presionado el botón izquierdo del mouse.
    if selectionFlag then
    begin
      //El rectángulo de selección se traza en sentido antihorario.
      with Image1.Canvas do begin
        //Realiza un primer trazo del rectángulo.
        Pen.mode := pmXor;
        MoveTo(StartPoint);
        LineTo(StartPoint.X, EndPoint.Y);
        LineTo(EndPoint);
        LineTo(EndPoint.X, StartPoint.Y);
        LineTo(StartPoint);
        //Traza el rectángulo a la par que se mueve el mouse.
        Pen.mode := pmXor;
        MoveTo(StartPoint);
        LineTo(StartPoint.X, Y);
        LineTo(X, Y);
        LineTo(X, StartPoint.Y);
        LineTo(StartPoint);
      end;
      //Se asegura de registrar el punto final de la selección.
      EndPoint := Point(X, Y);
    end;
  end;
end;

//Se activa al soltar el botón del mouse en la imagen.
procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //Termina la selección al dejar de presionar el botón izquierdo.
  if Button = mbLeft then
  begin
    //El rectángulo de selección se traza en sentido antihorario.
    with Image1.Canvas do begin
      //Asegura que el rectángulo de selección quede marcado en la imagen.
      Pen.Color := RGBToColor(94, 246, 255);
      Brush.Color := clWhite;
      Pen.mode := pmCopy;
      Pen.mode := pmMask;
      MoveTo(StartPoint);
      LineTo(StartPoint.X, EndPoint.Y);
      LineTo(EndPoint);
      LineTo(EndPoint.X, StartPoint.Y);
      LineTo(StartPoint);
    end;
    //Se desactiva la bandera de selección.
    selectionFlag := False;
  end;

  //Los cambios de deselección se aplican al dejar de presionar el botón derecho.
  if Button = mbRight then
  begin
    copMB(ALTO,ANCHO,MAT,BMAP);
    Image1.Picture.Assign(BMAP);
  end;

  //Verifica que la región seleccionada sea cuadrada para activar la binarización.
  If abs(EndPoint.X-StartPoint.X) = abs(EndPoint.Y-StartPoint.Y) then
    MenuItem11.Enabled := True
  else
    MenuItem11.Enabled := False;
end;

procedure TForm1.Label2Click(Sender: TObject);
begin

end;

//Procedimiento que pide parámetro r y aplica binarización dinámica.
procedure TForm1.MenuItem11Click(Sender: TObject);
var
  r  :  Integer;
begin
  r := 3;
  //Abre ventana para seleccionar r.
  Form2.setParameters(abs(EndPoint.X-StartPoint.X), abs(EndPoint.Y-StartPoint.Y));
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
    exchangeStartEnd();
    for i:=StartPoint.Y to EndPoint.Y do
    begin
      for j:=StartPoint.X to EndPoint.X do
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

//Aplica aumento de contraste usando Tanh.
procedure TForm1.MenuItem13Click(Sender: TObject);
var
  alpha : Float;
  i,j   : Integer;
  k     : Byte;
begin
  alpha := 0.01;
  //Abre ventana para seleccionar alpha.
  Form4.init();
  Form4.Showmodal;
  //En caso de haber seleccionado un valor alpha.
  if Form4.ModalResult = MROk then
  begin
    alpha := Form4.FloatSpinEdit1.Value;
    exchangeStartEnd();

    //Aplica el aumento de contraste a cada píxel.
    for i:=StartPoint.Y to EndPoint.Y do
      for j:=StartPoint.X to EndPoint.X do
        for k:=0 to 2 do
          MAT[i,j,k]:= round((255/2) * (1 + tanh(alpha * (MAT[i,j,k] - (255/2)))));

    //Se copia el resultado de la matriz al bitmap.
    copMB(ALTO,ANCHO,MAT,BMAP);
    //Visualizar el resultado en pantalla.
    Image1.Picture.Assign(BMAP);
    //Se actualiza el histograma de la imagen.
    grafHist();
  end;
end;

//Restaurar imagen a su estado original.
procedure TForm1.MenuItem14Click(Sender: TObject);
begin
  //Se asegura de restaurar las dimensiones originales de la matriz y el bitmap.
  ALTO := ALTO_origin;
  ANCHO := ANCHO_origin;
  BMAP.Height := ALTO;
  BMAP.Width := ANCHO;
  BMAPAUX.Height := ALTO;
  BMAPAUX.Width := ANCHO;
  SetLength(MAT,ALTO,ANCHO,3);
  SetLength(MAT2AUX,ALTO,ANCHO,3);
  //Copia el contenido de la matriz con el edo. original a la matriz de imagen.
  copMtoM(ALTO, ANCHO, MATOrigin, MAT);
  //Se guarda una copia en la matriz auxiliar.
  copMtoM(ALTO, ANCHO, MAT, MAT2AUX);
  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT,BMAP);
  //Actualiza y establece la selección para toda la imagen por defecto.
  StartPoint := Point(0,0);
  EndPoint := Point(ANCHO-1, ALTO-1);

  //Visualizar el resultado en pantalla.
  Image1.Picture.Assign(BMAP);
  Image2.Picture.Assign(BMAP);
  //Se actualiza el histograma de la imagen.
  grafHist();
  //MenuItem2.Enabled := True; //Habilita conversión a HSV
  //MenuItem9.Enabled := False; //Deshabilita conversión a RGB.
end;

//Guardar imagen.
procedure TForm1.MenuItem15Click(Sender: TObject);
begin
  if SavePictureDialog1.Execute then
    BMAP.SaveToFile(SavePictureDialog1.FileName);
end;

//Aplica reducción de contraste controlada mediante selección en histograma.
procedure TForm1.MenuItem16Click(Sender: TObject);
var
  i,j     :  Integer;
  k       :  Byte;
  iMin,iMax   : Array[0..2] of Integer;
  cMin,cMax   : Integer;
  auxCoord:  integer;
begin
  //Si en el histograma, el punto final de selección es menor al de inicio, se realiza el cambio.
  if EndHist.X< StartHist.X then
  begin
    auxCoord := StartHist.X;
    StartHist.X := EndHist.X;
    EndHist.X := auxCoord;
  end;
  exchangeStartEnd();

  //Se asignan las cotas mínima y máxima.
  cMin := StartHist.X;
  cMax := EndHist.X;

  //Inicializa los valores mínimos y máximos por canal.
  for k:=0 to 2 do
  begin
    iMin[k] := MAT[0, 0, k];
    iMax[k] := MAT[0, 0, k];
  end;
  //Calcula el mínimo y máximo de cada canal.
  for k:=0 to 2 do
    for i:=StartPoint.Y to EndPoint.Y do
      for j:=StartPoint.X to EndPoint.X do
        begin
          if MAT[i, j, k] < iMin[k] then
            iMin[k] := MAT[i, j, k];
          if MAT[i, j, k] > iMax[k] then
            iMax[k] := MAT[i, j, k];
        end;

  //Aplica la contracción a cada píxel.
  for i:=StartPoint.Y to EndPoint.Y do
    for j:=StartPoint.X to EndPoint.X do
      for k:=0 to 2 do
        MAT[i,j,k] := Round(((cMax - cMin)/(iMax[k] - iMin[k])) * (MAT[i,j,k] - iMin[k]) + cMin);

  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT,BMAP);
  //Visualizar el resultado en pantalla.
  Image1.Picture.Assign(BMAP);
  //Se actualiza el histograma de la imagen.
  grafHist();
end;

//Selecciona toda la imagen.
procedure TForm1.MenuItem18Click(Sender: TObject);
begin
  StartPoint := Point(0,0);
  EndPoint := Point(ANCHO-1, ALTO-1);
  //Desactiva la selección rectangular en la imagen.
  imgSelectionEnabled := False;

  //Limpia la última selección hecha.
  copMB(ALTO,ANCHO,MAT,BMAP);
  Image1.Picture.Assign(BMAP);

  //Verifica que la imagen sea cuadrada para activar la binarización.
  If abs(EndPoint.X-StartPoint.X) = abs(EndPoint.Y-StartPoint.Y) then
    MenuItem11.Enabled := True
  else
    MenuItem11.Enabled := False;
end;

//Activa la selección rectangular en la imagen.
procedure TForm1.MenuItem19Click(Sender: TObject);
begin
  imgSelectionEnabled := True;
end;

//Realiza operación de LBP.
procedure TForm1.MenuItem20Click(Sender: TObject);
begin

end;

//Permite que el usuario seleccione 4 colores y calcula la paleta correspondiente con interpolación lineal.
procedure TForm1.generarPaletaColores();
var
  i,j:  Integer;
  k: Byte;
  colors: Array[0..3] of Array[0..2] of Byte;
  c: Tcolor;
  d1,d2,d3 : Float;
  n1,n2,n3: Byte;
  l: Integer;
begin
  //Pide los 4 colores al usuario y los guarda en un arreglo.
  for k:=0 to 3 do
  begin
    If ColorDialog1.Execute then
    begin
      c := ColorDialog1.Color;
      colors[k,0] := GetRValue(c);
      colors[k,1] := GetGValue(c);
      colors[k,2] := GetBValue(c);
    end;
  end;
  //Cálcula distancias entre colores.
  d1 := sqrt(power(colors[1,0]-colors[0,0],2)+power(colors[1,1]-colors[0,1],2)+power(colors[1,2]-colors[0,2],2));
  d2 := sqrt(power(colors[2,0]-colors[1,0],2)+power(colors[2,1]-colors[1,1],2)+power(colors[2,2]-colors[1,2],2));
  d3 := sqrt(power(colors[3,0]-colors[2,0],2)+power(colors[3,1]-colors[2,1],2)+power(colors[3,2]-colors[2,2],2));
  //Obtiene la distancia total.
  l := round(d1+d2+d3);
  //Calcula los colores que habrán en cada segmento.
  n1 := round(255 * max(d1,max(d2,d3)) / l);
  n2 := round((255-n1) * min(d1,min(d2,d3)) / l);
  n3 := 255-n2-n1;
  j:=0; //Llevará el control de la paleta.
  //Calcula los colores correspondientes al primer segmento mediante interpolación lineal.
  for i:=0 to n1-1 do
  begin
    for k:=0 to 2 do
      paleta[j,k] := Round(colors[0,k] + (j/255)*(colors[1,k] - colors[0,k]));
    j:=j+1;
  end;
  //Calcula los colores correspondientes al segundo segmento mediante interpolación lineal.
  for i:=0 to n2-1 do
  begin
    for k:=0 to 2 do
      paleta[j,k] := Round(colors[1,k] + (j/255)*(colors[2,k] - colors[1,k]));
    j:=j+1;
  end;
  //Calcula los colores correspondientes al tercer segmento mediante interpolación lineal.
  for i:=0 to n3-1 do
  begin
    for k:=0 to 2 do
      paleta[j,k] := Round(colors[2,k] + (j/255)*(colors[3,k] - colors[2,k]));
    j:=j+1;
  end;
end;

//Aplica LBP por máximo.
procedure TForm1.MenuItem21Click(Sender: TObject);
var
  LBPMAT : MATRGB;
  LBPMATCOLOR : MATRGB;
  neighborPixels : Array[0..7] of Integer;
  i,j:  Integer;
  k,lbp: Byte;
  maximo: Integer;
begin
  //Calcula paleta de colores.
  generarPaletaColores();
  //Conversión a escala de grises.
  toGray();
  //Copia el contenido de la matriz original a las copias LBP.
  SetLength(LBPMAT,ALTO,ANCHO,3);
  copMtoM(ALTO, ANCHO, MAT, LBPMAT);
  SetLength(LBPMATCOLOR,ALTO,ANCHO,3);
  copMtoM(ALTO, ANCHO, MAT, LBPMATCOLOR);

  //Recorre toda la zona a excepción del margen.
  for i:=StartPoint.Y+1 to EndPoint.Y-1 do
  begin
    for j:=StartPoint.X+1 to EndPoint.X-1 do
    begin
      //Obtiene los valores de los 8 píxeles que rodean al píxel pívote.
      neighborPixels[0] := MAT[i-1,j-1,0];
      neighborPixels[1] := MAT[i-1,j,0];
      neighborPixels[2] := MAT[i-1,j+1,0];
      neighborPixels[3] := MAT[i,j+1,0];
      neighborPixels[4] := MAT[i+1,j+1,0];
      neighborPixels[5] := MAT[i+1,j,0];
      neighborPixels[6] := MAT[i+1,j-1,0];
      neighborPixels[7] := MAT[i,j-1,0];

      //Determina el valor máximo entre los píxeles vecinos.
      maximo := MaxValue(neighborPixels);

      //Cálculo del valor LBP para el píxel pívote.
      lbp := 0;
      for k:=0 to 7 do
        if neighborPixels[k] >= maximo then
          lbp := lbp + trunc(power(2,k));

      //Guarda el valor LBP en la matriz de LBP para todos los canales.
      LBPMAT[i,j,0] := lbp;
      LBPMAT[i,j,1] := lbp;
      LBPMAT[i,j,2] := lbp;
      //Se mapea el valor LBP respecto a un color dentro de la paleta y es guardado en otra matriz.
      LBPMATCOLOR[i,j,0] := paleta[lbp,0];
      LBPMATCOLOR[i,j,1] := paleta[lbp,1];
      LBPMATCOLOR[i,j,2] := paleta[lbp,2];
    end; //j
  end; //i

  //Se copia el resultado en la matriz de la imagen.
  copMtoM(ALTO, ANCHO, LBPMAT, MAT);
  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT,BMAP);
  //Visualizar el resultado en pantalla.
  Image1.Picture.Assign(BMAP);
  //Se actualiza el histograma de la imagen.
  grafHist();

  //Se copia el resultado del LBP con color en la matriz de la imagen auxiliar.
  copMtoM(ALTO, ANCHO, LBPMATCOLOR, MAT2AUX);
  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT2AUX,BMAPAUX);
  //Visualizar el resultado en pantalla.
  Image2.Picture.Assign(BMAPAUX);
end;

//Manda a llamar al método de rotación a la derecha (90°).
procedure TForm1.MenuItem23Click(Sender: TObject);
begin
  rotarImagen(true);
end;

//Manda a llamar al método de rotación a la izquierda (-90°).
procedure TForm1.MenuItem24Click(Sender: TObject);
begin
  rotarImagen(false);
end;

//Realiza operación de reflexión en X por cada mitad de la imagen.
procedure TForm1.MenuItem25Click(Sender: TObject);
var
  reflectedMAT : MATRGB;
  midANCHO : Integer;
  i,j   : Integer;
  k     : Byte;
begin
  //Obtiene la mitad del ancho de la imagen.
  midANCHO := trunc(ANCHO/2);
  SetLength(reflectedMAT,ALTO,ANCHO,3);
  //Refleja la mitad izquierda de la imagen.
  for i:=0 to ALTO-1 do
    for j:=0 to midANCHO-1 do
      for k:=0 to 2 do
        reflectedMAT[i,j,k] := MAT[i,midANCHO-j-1,k];
  //Refleja la mitad derecha de la imagen.
  for i:=0 to ALTO-1 do
    for j:=0 to ANCHO-midANCHO-1 do
      for k:=0 to 2 do
        reflectedMAT[i,midANCHO+j,k] := MAT[i,ANCHO-j-1,k];

  //Copia la matriz reflejada a la matriz de la imagen.
  copMtoM(ALTO,ANCHO,reflectedMAT,MAT);
  copMtoM(ALTO,ANCHO,reflectedMAT,MAT2AUX);

  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,reflectedMAT,BMAP);
  copMB(ALTO,ANCHO,reflectedMAT,BMAPAUX);
  //Visualizar el resultado en pantalla.
  Image1.Picture.Assign(BMAP);
  Image2.Picture.Assign(BMAP);
end;

//Aplica LBP por desviación estándar.
procedure TForm1.MenuItem26Click(Sender: TObject);
var
  LBPMAT : MATRGB;
  LBPMATCOLOR : MATRGB;
  neighborPixels : Array[0..7] of Double;
  i,j:  Integer;
  k,lbp: Byte;
  stdev: Double;
begin
  //Calcula paleta de colores.
  generarPaletaColores();
  //Conversión a escala de grises.
  toGray();
  //Copia el contenido de la matriz original a las copias LBP.
  SetLength(LBPMAT,ALTO,ANCHO,3);
  copMtoM(ALTO, ANCHO, MAT, LBPMAT);
  SetLength(LBPMATCOLOR,ALTO,ANCHO,3);
  copMtoM(ALTO, ANCHO, MAT, LBPMATCOLOR);

  //Recorre toda la zona a excepción del margen.
  for i:=StartPoint.Y+1 to EndPoint.Y-1 do
  begin
    for j:=StartPoint.X+1 to EndPoint.X-1 do
    begin
      //Obtiene los valores de los 8 píxeles que rodean al píxel pívote.
      neighborPixels[0] := MAT[i-1,j-1,0];
      neighborPixels[1] := MAT[i-1,j,0];
      neighborPixels[2] := MAT[i-1,j+1,0];
      neighborPixels[3] := MAT[i,j+1,0];
      neighborPixels[4] := MAT[i+1,j+1,0];
      neighborPixels[5] := MAT[i+1,j,0];
      neighborPixels[6] := MAT[i+1,j-1,0];
      neighborPixels[7] := MAT[i,j-1,0];

      //Calcula la desviación estándar de los píxeles vecinos.
      stdev := StdDev(neighborPixels);

      //Cálculo del valor LBP para el píxel pívote.
      lbp := 0;
      for k:=0 to 7 do
        if neighborPixels[k] >= stdev then
          lbp := lbp + trunc(power(2,k));

      //Guarda el valor LBP en la matriz de LBP para todos los canales.
      LBPMAT[i,j,0] := lbp;
      LBPMAT[i,j,1] := lbp;
      LBPMAT[i,j,2] := lbp;
      //Se mapea el valor LBP respecto a un color dentro de la paleta y es guardado en otra matriz.
      LBPMATCOLOR[i,j,0] := paleta[lbp,0];
      LBPMATCOLOR[i,j,1] := paleta[lbp,1];
      LBPMATCOLOR[i,j,2] := paleta[lbp,2];
    end; //j
  end; //i

  //Se copia el resultado en la matriz de la imagen.
  copMtoM(ALTO, ANCHO, LBPMAT, MAT);
  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT,BMAP);
  //Visualizar el resultado en pantalla.
  Image1.Picture.Assign(BMAP);
  //Se actualiza el histograma de la imagen.
  grafHist();

  //Se copia el resultado del LBP con color en la matriz de la imagen auxiliar.
  copMtoM(ALTO, ANCHO, LBPMATCOLOR, MAT2AUX);
  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT2AUX,BMAPAUX);
  //Visualizar el resultado en pantalla.
  Image2.Picture.Assign(BMAPAUX);
end;

//Aplica filtro circular de patrón.
procedure TForm1.MenuItem27Click(Sender: TObject);
var
  MATPATRON : MATRGB;
  BMAPATRON : TBitmap;
  newANCHO, newALTO, result : Integer;
  i,j  : Integer;
  k : Byte;
begin
  //Crea el objeto para guardar el patrón circular.
  BMAPATRON := TBitmap.Create;
  BMAPATRON.LoadFromFile('./patron.bmp');
  SetLength(MATPATRON,BMAPATRON.Height,BMAPATRON.Width,3);
  copBM(BMAPATRON.Height, BMAPATRON.Width, MATPATRON, BMAPATRON);

  //Define las dimensiones de la imagen resultante de la diferencia.
  newALTO := min(ALTO, BMAPATRON.Height);
  newANCHO := min(ANCHO, BMAPATRON.Width);

  //Se realiza la resta entre ambas imágenes.
  for i:=0 to newALTO-1 do
    for j:=0 to newANCHO-1 do
      for k:=0 to 2 do
      begin
        result := MAT[i,j,k] - MATPATRON[i,j,k];
        if result <= 0 then
          MAT[i,j,k] := 0
        else
          MAT[i,j,k] := result;
      end;

  //Se guarda una copia para el auxiliar de la imagen.
  copMtoM(ALTO, ANCHO, MAT, MAT2AUX);

  //Actualiza altos y anchos globales de la imagen, bitmap, bitmap auxiliar y matrices.
  ALTO := newALTO;
  ANCHO := newANCHO;
  BMAP.Height := newALTO;
  BMAP.Width := newANCHO;
  BMAPAUX.Height := newALTO;
  BMAPAUX.Width := newANCHO;
  SetLength(MAT,ALTO,ANCHO,3);
  SetLength(MAT2AUX,ALTO,ANCHO,3);

  //Actualiza y establece la selección para toda la imagen por defecto.
  StartPoint := Point(0,0);
  EndPoint := Point(ANCHO-1, ALTO-1);

  //Se copia el resultado de la matriz al bitmap.
  copMB(newALTO,newANCHO,MAT,BMAP);
  copMB(newALTO,newANCHO,MAT2AUX,BMAPAUX);
  Image1.Picture.Assign(BMAP); //Visualizar imagen.
  Image2.Picture.Assign(BMAPAUX);
  //Se actualiza el histograma de la imagen.
  grafHist();
end;

//Aplica gradiente para la detección de bordes.
procedure TForm1.MenuItem28Click(Sender: TObject);
var
  i,j  : Integer;
  k : Byte;
begin
  //Recorre toda la imagen y le aplica el gradiente por norma L1.
  for i:=StartPoint.Y to EndPoint.Y-1 do
  begin
    for j:=StartPoint.X to EndPoint.X-1 do
    begin
      for k:=0 to 2 do
        MAT[i,j,k] := round((0.5)*(abs(MAT[i+1,j,k] - MAT[i,j,k]) + abs(MAT[i,j+1,k] - MAT[i,j,k])));
    end; //j
  end; //i

  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT,BMAP);
  Image1.Picture.Assign(BMAP); //Visualizar imagen.
  //Se actualiza el histograma de la imagen.
  grafHist();
end;

//Aplica suavizado aritmético.
procedure TForm1.MenuItem29Click(Sender: TObject);
var
  RESCONVMAT : MATRGB;
  convArray : Array of Integer = (1,1,1,1,1,1,1,1);
  i,j:  Integer;
  k: Byte;
  suma: Integer;
begin
  //Copia el contenido de la matriz original a las copias LBP.
  SetLength(RESCONVMAT,ALTO,ANCHO,3);
  copMtoM(ALTO, ANCHO, MAT, RESCONVMAT);

  //Recorre toda la zona a excepción del margen.
  for i:=StartPoint.Y+1 to EndPoint.Y-1 do
  begin
    for j:=StartPoint.X+1 to EndPoint.X-1 do
    begin
      //Calcula la suma de las multiplicaciones de convolución.
      for k:=0 to 2 do
      begin
        suma := MAT[i-1,j-1,k] * convArray[0] + MAT[i-1,j,k] * convArray[1] + MAT[i-1,j+1,k] * convArray[2]
        + MAT[i,j-1,k] * convArray[3] + MAT[i,j+1,k] * convArray[4]
        + MAT[i+1,j-1,k] * convArray[5] + MAT[i+1,j,k] * convArray[6] + MAT[i+1,j+1,k] * convArray[7];

        //Determina el promedio de la suma y lo asigna al píxel pívote.
        RESCONVMAT[i,j,k] := round(suma/8);
      end; //k
    end; //j
  end; //i

  //Se copia el resultado de la convolución en la matriz de la imagen.
  copMtoM(ALTO, ANCHO, RESCONVMAT, MAT);
  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT,BMAP);
  //Visualizar el resultado en pantalla.
  Image1.Picture.Assign(BMAP);
  //Se actualiza el histograma de la imagen.
  grafHist();
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
       M[i,j,0]:=P[k+2];
       M[i,j,1]:=P[k+1];
       M[i,j,2]:=P[k];
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
       P[k+2] := M[i,j,0];
       P[k+1] := M[i,j,1];
       P[k] := M[i,j,2];
    end; //j
  end; //i
end;

//Copiar de Matriz a Matriz.
procedure Tform1.copMtoM(al,an:Integer; var MOrigin:MATRGB; var MCopy:MATRGB);
var
  i,j : Integer;
  k :  Byte;
begin
  for i:=0 to al-1 do
    for j:=0 to an-1 do
      for k:=0 to 2 do
        MCopy[i,j,k] := MOrigin[i,j,k];
end;

//Intercambia los puntos de origen y fin de la selección.
procedure tform1.exchangeStartEnd();
var
  auxCoord:  integer;
begin
  //Si en Y el punto final es menor al de inicio, se realiza el cambio.
  if EndPoint.Y < StartPoint.Y then
  begin
    auxCoord := StartPoint.Y;
    StartPoint.Y := EndPoint.Y;
    EndPoint.Y := auxCoord;
  end;
  //Si en X el punto final es menor al de inicio, se realiza el cambio.
  if EndPoint.X< StartPoint.X then
  begin
    auxCoord := StartPoint.X;
    StartPoint.X := EndPoint.X;
    EndPoint.X := auxCoord;
  end;
end;

//Graficar histograma de la imagen.
procedure tform1.grafHist();
var
  i,j, nPixels :  Integer;
  k,val   :  Byte;
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
  exchangeStartEnd();
  for i:=StartPoint.Y to EndPoint.Y do
  begin
    for j:=StartPoint.X to EndPoint.X do
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
  exchangeStartEnd();
  regionesAn := trunc(abs(EndPoint.X - StartPoint.X + 1) / r);
  regionesAl := trunc(abs(EndPoint.Y - StartPoint.Y + 1) / r);
  //Aplicamos la binarización en la región regy,regx de rxr píxeles.
  for regy:=0 to regionesAl-1 do
  begin
    for regx:=0 to regionesAn-1 do
    begin
      //Se determina límite regional en lo alto.
      limitRegY := StartPoint.Y + (regy+1)*r-1;
      //Se obtiene la suma de las intensidades de los píxeles en la región.
      mean := 0;
      for i:=StartPoint.Y+regy*r to limitRegY do
      begin
        //Se determina límite regional en el ancho.
        limitRegX := StartPoint.X + (regx+1)*r-1;
        for j:=StartPoint.X+regx*r to limitRegX do
        begin
          mean := mean + MAT[i,j,0];
        end; //j
      end; //i

      //Se obtiene el promedio de las intensidades.
      mean := round(mean /(r*r));

      //Se aplica la binarización a cada píxel de la región.
      for i:=StartPoint.Y+regy*r to limitRegY do
      begin
        //Se determina límite regional en el ancho.
        limitRegX := StartPoint.X + (regx+1)*r-1;
        for j:=StartPoint.X+regx*r to limitRegX do
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
  anchoSobrante := EndPoint.X - lastPixelX;
  altoSobrante := EndPoint.Y - lastPixelY;

  //********************************** Binarización de píxeles sobrantes a lo ancho **********************************
  //Verifica que existan píxeles sobrantes a lo ancho.
  if anchoSobrante > 0 then
  begin
    //El alto se dividirá en 3 regiones de r píxeles.
    r := trunc(abs(EndPoint.Y - StartPoint.Y) / 3);
    //Aplicamos la binarización a las 3 regiones.
    for regy:=0 to 2 do
    begin
      //Se determina límite regional en lo alto.
      //Si es la última región, entonces se tomarán los píxeles que resten del alto.
      if regy = 2 then
        limitRegY := EndPoint.Y
      else
        limitRegY := StartPoint.Y + (regy+1)*r;

      //Se obtiene la suma de las intensidades de los píxeles en la región.
      mean := 0;
      for i:=StartPoint.Y + regy*r to limitRegY do
      begin
        for j:=lastPixelX to EndPoint.X do
        begin
          mean := mean + MAT[i,j,0];
        end; //i
      end; //j

      //Se obtiene el promedio de las intensidades.
      mean := round(mean / (((limitRegY - (StartPoint.Y + regy*r)) + 1) * anchoSobrante));

      //Se aplica la binarización a cada píxel de la región.
      for i:=StartPoint.Y + regy*r to limitRegY do
      begin
        for j:= lastPixelX to EndPoint.X do
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
    r := trunc(abs(EndPoint.X - lastPixelX) / 3);
    //Aplicamos la binarización a las 3 regiones.
    for regx:=0 to 2 do
    begin
      //Se determina límite regional en lo ancho.
      //Si es la última región, entonces se tomarán los píxeles que resten del ancho.
      if regx = 2 then
        limitRegX := lastPixelX
      else
        limitRegX := StartPoint.X + (regx+1)*r;

      //Se obtiene la suma de las intensidades de los píxeles en la región.
      mean := 0;
      for i:=lastPixelY to EndPoint.Y do
      begin
        for j:=StartPoint.X + regx*r to limitRegX do
        begin
          mean := mean + MAT[i,j,0];
        end; //i
      end; //j

      //Se obtiene el promedio de las intensidades.
      mean := round(mean / (((limitRegX - (StartPoint.X + regx*r)) + 1) * altoSobrante));

      //Se aplica la binarización a cada píxel de la región.
      for i:=lastPixelY to EndPoint.Y do
      begin
        for j:=StartPoint.X + regx*r to limitRegX do
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

  //Se guarda una copia en la matriz auxiliar.
  copMtoM(ALTO, ANCHO, MAT, MAT2AUX);
  //Se copia el resultado de la matriz al bitmap.
  copMB(ALTO,ANCHO,MAT,BMAP);
  //Visualizar el resultado en pantalla.
  Image1.Picture.Assign(BMAP);
  //Se actualiza el histograma de la imagen.
  grafHist();
end;

//Rota la imagen 90° o -90°.
procedure tform1.rotarImagen(direction: Boolean);
var
  rotatedMAT : MATRGB;
  newANCHO, newALTO : Integer;
  i,j   : Integer;
  k     : Byte;
begin
  //Define las dimensiones de la nueva imagen.
  newANCHO := ALTO;
  newALTO := ANCHO;
  SetLength(rotatedMAT,newALTO,newANCHO,3);

  //Se realiza la rotación de la imagen a 90°.
  If direction = true then
    for i:=0 to newALTO-1 do
      for j:=0 to newANCHO-1 do
        for k:=0 to 2 do
          rotatedMAT[i,j,k] := MAT[j,newALTO-i-1,k]
  //Se realiza la rotación de la imagen a -90°.
  else
    for i:=0 to newALTO-1 do
      for j:=0 to newANCHO-1 do
        for k:=0 to 2 do
          rotatedMAT[i,j,k] := MAT[newANCHO-j-1,i,k];

  //Actualiza altos y anchos globales de la imagen y del bitmap.
  ALTO := newALTO;
  ANCHO := newANCHO;
  BMAP.Height := newALTO;
  BMAP.Width := newANCHO;
  BMAPAUX.Height := newALTO;
  BMAPAUX.Width := newANCHO;

  //Actualiza y establece la selección para toda la imagen por defecto.
  StartPoint := Point(0,0);
  EndPoint := Point(ANCHO-1, ALTO-1);

  //Copia la matriz rotada a la matriz de la imagen.
  SetLength(MAT,ALTO,ANCHO,3);
  copMtoM(ALTO,ANCHO,rotatedMAT,MAT);
  SetLength(MAT2AUX,ALTO,ANCHO,3);
  copMtoM(ALTO,ANCHO,rotatedMAT,MAT2AUX);

  //Se copia el resultado de la matriz al bitmap.
  copMB(newALTO,newANCHO,rotatedMAT,BMAP);
  copMB(newALTO,newANCHO,rotatedMAT,BMAPAUX);
  //Visualizar el resultado en pantalla.
  Image1.Picture.Assign(BMAP);
  Image2.Picture.Assign(BMAPAUX);
end;

end.
