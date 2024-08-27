unit Byte.Lib;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.IOUtils,
  System.StrUtils,
  System.RegularExpressions,
  System.UITypes,
  System.MaskUtils,
  System.DateUtils,
  System.Math,

  Data.DB,
  Byte.Consts,

  IdCoderMIME,
  {$IFDEF MSWINDOWS}
  Vcl.Controls,
  ShellAPI,
  Registry,
  Winapi.Windows,
  Winapi.Messages,
  {$ENDIF}
  //Componentes Indy
  IdComponent,
  IdTCPConnection,
  IdTCPClient,
  IdHTTP,
  IdBaseComponent,
  IdMessage,
  IdExplicitTLSClientServerBase,
  IdMessageClient,
  IdSMTPBase,
  IdSMTP,
  IdIOHandler,
  IdIOHandlerSocket,
  IdIOHandlerStack,
  IdSSL,
  IdSSLOpenSSL,
  IdSSLOpenSSLHeaders,
  IdAttachmentFile,
  IdText;

type
  TProcedureExcept = reference to procedure (const AExcpetion: String);

  TTipoValidacao = (tvCPFCNPJ, tvEmail, tvFixoCelular, tvRG, tvIE, tvCEP);

  TLib = class
    private
      class function FormatarCnpj(const Valor: string): string;
      class function FormatarCpf(const Valor: string): string;
      class function SimpleRoundToEX(const AValue: Extended; const ADigit: TRoundToRange = -2): Extended;
    public
      {Funcões uteis}
      class procedure CustomThread(
          AOnStart,             //procedimento de entrada
          AOnProcess,           //procedimento principal
          AOnComplete : TProc;  //procedimento de finalização
          AOnError    : TprocedureExcept = nil;
          const ADoCompleteWithError: Boolean = True
      );
      class function ClearDirectory(aDirectory : String) : Boolean;
      class function CheckInternet(AHost: string = 'www.google.com'; APort: integer = 80): Boolean;
      class procedure VCL_OpenPDF(AFile: TFileName; ATypeForm: Integer);
      class function GetRandomNumber(AStartNum, AEndNum: integer): integer;
      class function IIf(pCond:Boolean;pTrue,pFalse:Variant): Variant;
      class function MyBoolToStr(S: Boolean): string;
      class function MyStrToBool(S: string): boolean;
      class function Extenso(pValor: extended): String;
      class function UltimosXDigitos(const S: string; NumDigitos: Integer): string;
      class procedure RegistraInicializarWindows(const AProgTitle: string; const AExePath: string; ARunOnce: Boolean);
      {$IFDEF MSWINDOWS}
      class procedure VclRoundCornerOf(Control: TWinControl);
      {$ENDIF}
      {Funções de formatação}
      class function FormatarDocumento(pTexto: string): string;
      class function SomenteNumero(const AValue: string): string;
      class function SomenteLetras(const AValue: String): string;
      class function PoeZeros(Valor: String; Tamanho,Decimais:Integer): String;
      class function RemoveAcento(AString: String): String;
      class function PadC(sTexto: string; iTamanho: Integer): string;
      class function padL(const AString: String; const nLen : Integer; const Caracter : AnsiChar = ' ') : String;
      class function Padr(s:string;n:integer):string;

      {Funções matematicas}
      class function RoundABNT(const AValue: Double; const Digits: TRoundToRange; const Delta: Double = 0.00001 ): Double;
      class function RoundTo2(const AValue: Double; const ADigit: TRoundToRange): Double;

      {Funções de validação}
      class function IsCNPJ(AValue: string): boolean;
      class function IsCPF(AValue: string): boolean;
      class function Valida(AValue: String; ATipoValidacao: TTipoValidacao): Boolean;

      {FUNÇÕES BASE64}
      class function Base64_Encode(AFile: string): string;
      class procedure Base64_Decode(ABase64: string; AStream: TMemoryStream);

      {Encriptação}
      class function Crypt(Texto,Chave :String): String;
      class function Crypto (aText: string): string;
      class function Decrypto (aText: string): string; overload;
      class function Decrypto (aText, aChave: string): string; overload;
      class function CryptSameTextLength(Texto,Chave :String): String;
  end;

implementation

{ TLib }

{$REGION 'FUNÇÕES UTEIS'}

class function TLib.CheckInternet(AHost: string; APort: integer): Boolean;
var
  LIDTCPClient: TIdTCPClient;
begin
  Result := False;
  try
    try
      LIDTCPClient                 := TIdTCPClient.Create(nil);
      LIDTCPClient.ReadTimeout     := 2000;
      LIDTCPClient.ConnectTimeout  := 2000;
      LIDTCPClient.Port            := APort;
      LIDTCPClient.Host            := AHost;
      LIDTCPClient.Connect;
      LIDTCPClient.Disconnect;
      Result:= True;
    except
      on E:Exception do begin
        Result := False;
        raise Exception.Create('Sem conexão com a internet.');
      end;
    end;
  finally
    LIDTCPClient.DisposeOf;
    LIDTCPClient := nil;
  end;
end;

class function TLib.ClearDirectory(aDirectory: String): Boolean;
var
  SR: TSearchRec;
  I: integer;
begin
  I := FindFirst(aDirectory + '*.*', faAnyFile, SR);
  while I = 0 do begin
    if (SR.Attr and faDirectory) <> faDirectory then begin
      if not DeleteFile(PChar(aDirectory + SR.Name)) then begin
        Result := False;
        Exit;
      end;
    end;
    I := FindNext(SR);
  end;
  Result := True;
end;

class procedure TLib.CustomThread(AOnStart, AOnProcess, AOnComplete: TProc; AOnError: TprocedureExcept; const ADoCompleteWithError: Boolean);
var
  vThread: TThread;
begin
  vThread:= TThread.CreateAnonymousThread(
    procedure ()
    var
      vDoComplete : Boolean;
    begin
      try
        try
          vDoComplete:= True;
          if Assigned(AOnStart) then begin
            TThread.Synchronize(
              TThread.CurrentThread,
              procedure ()
              begin
                AOnStart;
              end
            );
          end;

          if Assigned(AOnProcess) then
            AOnProcess;

        except on E:Exception do
          begin
            vDoComplete:= ADoCompleteWithError;
            if Assigned(AOnError) then begin
              TThread.Synchronize(
                TThread.CurrentThread,
                procedure ()
                begin
                  AOnError(E.Message);
                end
              );
            end;
          end;
        end;
      finally
        //Complete
        if Assigned(AOnComplete) and vDoComplete then begin
          TThread.Synchronize(
            TThread.CurrentThread,
            procedure ()
            begin
              AOnComplete;
            end
          );
        end;
      end;
    end
  );
  vThread.FreeOnTerminate:= True;
  vThread.Start;
end;

class function TLib.GetRandomNumber(AStartNum, AEndNum: integer): integer;
begin
  Result:= AStartNum + Random(AEndNum);
end;

class procedure TLib.VCL_OpenPDF(AFile: TFileName; ATypeForm: Integer);
var
  vDir: PChar;
begin
{$IFDEF MSWINDOWS}
  GetMem(vDir, 256);
  StrPCopy(vDir, AFile);
  ShellExecute(0, nil, PChar(AFile), nil, vDir, ATypeForm);
  FreeMem(vDir, 256);
{$ENDIF}
end;

class function TLib.IIf(pCond: Boolean; pTrue, pFalse: Variant): Variant;
begin
  If pCond Then Result:= pTrue else Result:= pFalse;
end;

//Converte boolean para string - S = True N = False
class function TLib.MyBoolToStr(S: Boolean): string;
begin
  Result := 'N';
  If S then Result := 'S';
end;

//Converte string para boolean - S = True N = False
class function TLib.MyStrToBool(S: string): boolean;
begin
  Result := false;
  if S = 'S' then Result := True;
end;

//------------------------------------------------------------------------------
// função que retorna valores em extenso
// esta função tem uma limitação. no caso este projeto foi desenvolvido no
// Delphi 3, e no Delphi 3 ainda não existia o tipo de dado LongWord, que
// seria um LongInt com o dobro da capacidade. Sendo assim, a função fica
// limitada para traduzir números até 2147483647. Se for usado o parâmetro
// com o tipo LongWord, podemos usar até 4294967295.
//------------------------------------------------------------------------------
class function TLib.Extenso(pValor: extended): String;
const
  Unidades: array[1..19] of string = ('um', 'dois', 'três', 'quatro','cinco', 'seis', 'sete', 'oito', 'nove', 'dez', 'onze', 'doze',
  'treze', 'quatorze', 'quinze', 'dezesseis', 'dezessete', 'dezoito','dezenove');

  Dezenas: array[1..9] of string = ('dez', 'vinte', 'trinta', 'quarenta','cinqüenta', 'sessenta', 'setenta', 'oitenta', 'noventa');
  Centenas: array[1..9] of string = ('cem', 'duzentos', 'trezentos','quatrocentos', 'quinhentos', 'seiscentos', 'setecentos',          'oitocentos','novecentos');
  Min = 0.01;
  Max = 4294967295.99;
  ErrorString = 'Valor fora da faixa';
  Moeda = ' real ';
  Moedas = ' reais ';
  Centesimo = ' centavo ';
  Centesimos = ' centavos ';
var
  lResultado : string;
  //myE : erangeerror;

      //------------------------------------------------------------------------
      function ConversaoRecursiva(N: LongInt): string;
      begin
        case N of
                1..19:
                        Result := Unidades[N];
                20, 30, 40, 50, 60, 70, 80, 90:
                        Result := Dezenas[N div 10] + ' ';
                21..29, 31..39, 41..49, 51..59, 61..69, 71..79, 81..89, 91..99:
                        Result := Dezenas[N div 10] + ' e ' + ConversaoRecursiva(N mod 10);
                100, 200, 300, 400, 500, 600, 700, 800, 900:
                        Result := Centenas[N div 100] + ' ';
                101..199:
                        Result := ' cento e ' + ConversaoRecursiva(N mod 100);
                201..299, 301..399, 401..499, 501..599, 601..699, 701..799, 801..899, 901..999:
                        Result := Centenas[N div 100] + ' e ' + ConversaoRecursiva(N mod 100);
                1000..999999:
                        Result := ConversaoRecursiva(N div 1000) + ' mil ' + ConversaoRecursiva(N mod 1000);
                1000000..1999999:
                        Result := ConversaoRecursiva(N div 1000000) + ' milhão '+ ConversaoRecursiva(N mod 1000000);
                2000000..999999999:
                        Result := ConversaoRecursiva(N div 1000000) + ' milhões '+ ConversaoRecursiva(N mod 1000000);
                1000000000..1999999999:
                        Result := ConversaoRecursiva(N div 1000000000) + ' bilhão ' + ConversaoRecursiva(N mod 1000000000);
                //Se existir definição de longWord na versão do Delphi, pode usar 4294967295 e trocar o tipo do parâmetro da função para LongWord
                2000000000..2147483647:
                        Result := ConversaoRecursiva(N div 1000000000) + ' bilhões ' + ConversaoRecursiva(N mod 1000000000);
        end;
      end;

begin // início Extenso
  try try
    if (pValor >= Min) and (pValor <= Max) then
    begin
      //Tratar reais
      lResultado := ConversaoRecursiva(Round(Int(pValor)));
      if Round(Int(pValor)) = 1 then
          lResultado := lResultado + Moeda
      else
          if Round(Int(pValor)) <> 0 then
             lResultado := lResultado + Moedas;

      //Tratar centavos
      if not(Frac(pValor) = 0.00) then
      begin
        if Round(Int(pValor)) <> 0 then
          lResultado := lResultado + ' e ';
        lResultado := lResultado + ConversaoRecursiva(Round(Frac(pValor) * 100));
        if (Round(Frac(pValor) * 100) = 1) then
          lResultado := lResultado + centesimo
        else
          lResultado := lResultado + centesimos;
      end;
    end
    else
       begin // temos erros. tratar exceção. retorno como resultado uma exceção.
         //if(pRetornaErroVazio) then
           lResultado := '';
         //else begin
         //       myE := ERangeError.CreateFmt(ErrorString + ' (%g). Intervalo aceito: %g..%g',[pValor, Min, Max]);
         //       lResultado := myE.Message;
         //     end;
       end;
  except
    lResultado := 'erro no except';
  end;
  finally
    result := lResultado;
  end;
end;

class function TLib.FormatarCnpj(const Valor: string): string;
begin
  Result := Valor;
  if Length(Result) > 12 then
    Insert('-', Result, 13);
  if Length(Result) > 8 then
    Insert('/', Result, 9);
  if Length(Result) > 5 then
    Insert('.', Result, 6);
  if Length(Result) > 2 then
    Insert('.', Result, 3);
end;

class function TLib.FormatarCpf(const Valor: string): string;
begin
  Result := Valor;
  if Length(Result) > 9 then
    Insert('-', Result, 10);
  if Length(Result) > 6 then
    Insert('.', Result, 7);
  if Length(Result) > 3 then
    Insert('.', Result, 4);
end;

class function TLib.FormatarDocumento(pTexto: string): string;
begin
  pTexto:= SomenteNumero(pTexto);
  if Length(pTexto) <= 14 then begin
    if Length(pTexto) <= 11 then
      Result := FormatarCpf(pTexto)
    else
      Result := FormatarCnpj(pTexto);
  end;
end;

class function TLib.UltimosXDigitos(const S: string; NumDigitos: Integer): string;
var
  StartPos: Integer;
begin
  StartPos := Length(S) - NumDigitos + 1;
  if StartPos < 1 then
    StartPos := 1;
  Result := Copy(S, StartPos, NumDigitos);
end;

class procedure TLib.RegistraInicializarWindows(const AProgTitle, AExePath: string; ARunOnce: Boolean);
var
  vSKey: string;
  {$IFDEF MSWINDOWS}
  vReg: TRegIniFile;
  {$ENDIF}
begin
  if (AProgTitle.IsEmpty) or (AExePath.IsEmpty) then
    Exit;
{$IFDEF MSWINDOWS}
  vSKey:= '';
  if ARunOnce then
    vSKey:= 'Once';

  vReg:= TRegIniFile.Create('');
  try
    vReg.RootKey:= HKEY_LOCAL_MACHINE;
    vReg.WriteString('Software\Microsoft\Windows\CurrentVersion\Run' + vSKey + #0, AProgTitle, AExePath);
  finally
    vReg.Free;
  end;
{$ENDIF}
end;

{$ENDREGION}

{$REGION 'FUNÇÕES DE FORMATAÇÃO'}

class function TLib.PoeZeros(Valor: String; Tamanho, Decimais: Integer): String;
var
  Inteiro, Fracao: String;
begin
  if Pos('.',Valor) > 0 then begin
    Inteiro := Copy(Valor,1,Pos('.',Valor)-1);
    Fracao := Copy(Valor,Pos('.',Valor)+1,Length(Valor));
    while Length(Inteiro) < Tamanho do Inteiro := '0' + Inteiro;
    while Length(Fracao) < Decimais do Fracao := Fracao + '0';
    Valor := Inteiro + Fracao;
  end else while Length(Valor) < Tamanho do Valor := '0' + Valor;
  Result := Valor;
end;

class function TLib.RemoveAcento(AString: String): String;
Const
  ComAcento = 'àâêôûãõáéíóúçüÀÂÊÔÛÃÕÁÉÍÓÚÇÜ°';
  SemAcento = 'aaeouaoaeioucuAAEOUAOAEIOUCU ';
var
  x : Integer;
Begin
  For x := 1 to Length(AString) do
    if Pos(AString[x],ComAcento)<>0 Then
      AString[x] := SemAcento[Pos(AString[x],ComAcento)];
  Result := AString;
end;

class function TLib.RoundABNT(const AValue: Double; const Digits: TRoundToRange; const Delta: Double): Double;
var
   Pow, FracValue, PowValue : Extended;
   RestPart: Double;
   IntCalc, FracCalc, LastNumber, IntValue : Int64;
   Negativo: Boolean;
Begin
   Negativo  := (AValue < 0);

   Pow       := intpower(10, abs(Digits) );
   PowValue  := abs(AValue) / 10 ;
   IntValue  := trunc(PowValue);
   FracValue := frac(PowValue);

   PowValue := SimpleRoundToEX( FracValue * 10 * Pow, -9) ; // SimpleRoundTo elimina dizimas ;
   IntCalc  := trunc( PowValue );
   FracCalc := trunc( frac( PowValue ) * 100 );

   if (FracCalc > 50) then
     Inc( IntCalc )

   else if (FracCalc = 50) then
   begin
     LastNumber := round( frac( IntCalc / 10) * 10);

     if odd(LastNumber) then
       Inc( IntCalc )
     else
     begin
       RestPart := frac( PowValue * 10 ) ;

       if RestPart > Delta then
         Inc( IntCalc );
     end ;
   end ;

   Result := ((IntValue*10) + (IntCalc / Pow));
   if Negativo then
     Result := -Result;
end;

class function TLib.RoundTo2(const AValue: Double; const ADigit: TRoundToRange): Double;
var
  LFactor: Double;
begin
  LFactor := IntPower(10, ADigit);
  Result := Round((AValue / LFactor) + 0.05) * LFactor;
end;

class function TLib.SimpleRoundToEX(const AValue: Extended; const ADigit: TRoundToRange): Extended;
var
  LFactor: Extended;
begin
  LFactor := IntPower(10.0, ADigit);
  if AValue < 0 then
    Result := Int((AValue / LFactor) - 0.5) * LFactor
  else
    Result := Int((AValue / LFactor) + 0.5) * LFactor;
end;

class function TLib.SomenteLetras(const AValue: String): string;
var
  vStr: String;
  I: integer;
begin
  Result:= '';
  vStr:= UpperCase(AValue);
  for I := 1 to Length(vStr) do
    if CharInSet(vStr[I],
    ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'X', 'Y', 'W', 'Z', ' ']) then
      Result:= Result + vStr[I];
end;

class function TLib.SomenteNumero(const AValue: string): string;
var
  I: integer;
  vStr: String;
begin
  Result:= EmptyStr;
  for I := 1 to Length(AValue) do begin
    vStr:= Copy(AValue, I, 1);
    case AnsiIndexStr((vStr), [
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) of
      0,1,2,3,4,5,6,7,8,9: Result:= Result + vStr;
    else

    end;
  end;
end;

class function TLib.PadC(sTexto: string; iTamanho: Integer): string;
var
  iContador                   : Integer;
  iPosicao                    : Integer;
begin
  Result := sTexto;
  iPosicao := Trunc((iTamanho - Length(Result)) / 2);
  for iContador := 1 to iPosicao do
    Result := ' ' + Result;
  iPosicao := (iTamanho - Length(Result));
  for iContador := 1 to iPosicao do
    Result := Result + ' ';
end;

{-----------------------------------------------------------------------------
  Completa <AString> com <Caracter> a direita, até o tamanho <nLen>, Alinhando
  a <AString> a Esquerda. Se <AString> for maior que <nLen>, ela será truncada
  - tirada da unit ACBrUtil
 ---------------------------------------------------------------------------- }
class function TLib.padL(const AString: String; const nLen: Integer; const Caracter: AnsiChar): String;
var
  Tam: Integer;
begin
  Tam := Length(AString);
  if Tam < nLen then
    Result := AString + StringOfChar(Caracter, (nLen - Tam))
  else
    Result := copy(AString,1,nLen) ;
end;

class function TLib.Padr(s: string; n: integer): string;
begin
  Result:=Format('%'+IntToStr(n)+'.'+IntToStr(n)+'s',[s]);
end;

{$ENDREGION}

{$REGION 'FUNÇÕES DE VALIDAÇÃO'}

class function TLib.IsCNPJ(AValue: string): boolean;
var
  dig13, dig14: string;
  sm, i, r, peso: integer;
begin
  aValue := SomenteNumero(aValue);
  // length - retorna o tamanho da string do CNPJ (CNPJ é um número formado por 14 dígitos)
  if ((aValue = '00000000000000') or (aValue = '11111111111111') or
     (aValue = '22222222222222') or (aValue = '33333333333333') or
     (aValue = '44444444444444') or (aValue = '55555555555555') or
     (aValue = '66666666666666') or (aValue = '77777777777777') or
     (aValue = '88888888888888') or (aValue = '99999999999999') or
     (aValue.Length <> 14))
  then begin
    isCNPJ := False;
    Exit;
  end;

  // "try" - protege o código para eventuais erros de conversão de tipo através da função "StrToInt"
  try
    { *-- Cálculo do 1o. Digito Verificador --* }
    sm := 0;
    peso := 2;
    for i := 12 downto 1 do begin
      // StrToInt converte o i-ésimo caractere do CNPJ em um número
      sm := sm + (StrToInt(Copy(aValue, i, 1)) * peso);
      peso := peso + 1;
      if (peso = 10) then
        peso := 2;
    end;

    r := sm mod 11;
    if ((r = 0) or (r = 1)) then
      dig13 := '0'
    else
      str((11-r):1, dig13); // converte um número no respectivo caractere numérico

    { *-- Cálculo do 2o. Digito Verificador --* }
    sm := 0;
    peso := 2;
    for i := 13 downto 1 do begin
      sm := sm + (StrToInt(Copy(aValue, i, 1)) * peso);
      peso := peso + 1;
      if (peso = 10) then
        peso := 2;
    end;

    r := sm mod 11;
    if ((r = 0) or (r = 1)) then
      dig14 := '0'
    else
      str((11-r):1, dig14);

    { Verifica se os digitos calculados conferem com os digitos informados. }
    if ((dig13 = Copy(aValue, 13, 1)) and (dig14 = Copy(aValue, 14, 1))) then
      isCNPJ := true
    else
      isCNPJ := False;
  except
    isCNPJ := False
  end;
end;

class function TLib.IsCPF(AValue: string): boolean;
var
  dig10, dig11: string;
  s, i, r, peso: integer;
begin
  aValue := SomenteNumero(aValue);
  // length - retorna o tamanho da string (CPF é um número formado por 11 dígitos)
  if ((aValue = '00000000000') or (aValue = '11111111111') or
  (aValue = '22222222222') or (aValue = '33333333333') or
  (aValue = '44444444444') or (aValue = '55555555555') or
  (aValue = '66666666666') or (aValue = '77777777777') or
  (aValue = '88888888888') or (aValue = '99999999999') or
  (aValue.Length <> 11))
  then begin
  isCPF := false;
  exit;
  end;

  // try - protege o código para eventuais erros de conversão de tipo na função StrToInt
  try
    { *-- Cálculo do 1o. Digito Verificador --* }
    s := 0;
    peso := 10;
    for i := 1 to 9 do
    begin
      // StrToInt converte o i-ésimo caractere do CPF em um número
      s := s + (StrToInt(Copy(aValue, i, 1)) * peso);
      peso := peso - 1;
    end;

    r := 11 - (s mod 11);
    if ((r = 10) or (r = 11))
    then
      dig10 := '0'
    else
      str(r:1, dig10); // converte um número no respectivo caractere numérico

    { *-- Cálculo do 2o. Digito Verificador --* }
    s := 0;
    peso := 11;
    for i := 1 to 10 do
    begin
      s := s + (StrToInt(Copy(aValue, i, 1)) * peso);
      peso := peso - 1;
    end;

    r := 11 - (s mod 11);
    if ((r = 10) or (r = 11))
    then
      dig11 := '0'
    else
      str(r:1, dig11);

    { Verifica se os digitos calculados conferem com os digitos informados. }
    if ((dig10 = Copy(aValue, 10, 1)) and (dig11 = Copy(aValue, 11, 1)))
    then
      isCPF := true
    else
      isCPF := false;
  except
    isCPF := false
  end;
end;

class function TLib.Valida(AValue: String; ATipoValidacao: TTipoValidacao): Boolean;
begin
  Result:= False;

  if AValue.IsEmpty then
    Exit;

  case ATipoValidacao of
    tvCPFCNPJ: begin
      Result:= TRegEx.IsMatch(AValue, C_EXP_CPF_CNPJ);
    end;
    tvEmail: begin
      Result:= TRegEx.IsMatch(AValue, C_EXP_EMAIL);
    end;
    tvFixoCelular: begin
      Result:= TRegEx.IsMatch(AValue, C_EXP_FIXO_CEL);
    end;
    tvRG: begin
      Result:= TRegEx.IsMatch(AValue, C_EXP_RG);
    end;
    tvIE: begin
      Result:= TRegEx.IsMatch(AValue, C_EXP_INSCRICAO);
    end;
    tvCEP: begin
      Result:= TRegEx.IsMatch(AValue, C_EXP_CEP);
    end;
  end;
end;

class procedure TLib.VclRoundCornerOf(Control: TWinControl);
var
   R: TRect;
   Rgn: HRGN;
begin
   with Control do
   begin
     R := ClientRect;
     rgn := CreateRoundRectRgn(R.Left, R.Top, R.Right, R.Bottom, 20, 20) ;
     Perform(EM_GETRECT, 0, lParam(@r)) ;
     InflateRect(r, - 4, - 4) ;
     Perform(EM_SETRECTNP, 0, lParam(@r)) ;
     SetWindowRgn(Handle, rgn, True) ;
     Invalidate;
   end;
end;

{$ENDREGION}


{$REGION 'FUNÇÕES BASE64'}

class function TLib.Base64_Encode(AFile: string): string;
var
  vStream: TFileStream;
  vBase64: TIdEncoderMIME;
  vOutput: string;
begin
  if FileExists(AFile) then begin
    try
      try
        vBase64:= TIdEncoderMIME.Create(nil);
        vStream:= TFileStream.Create(AFile, fmOpenRead);
        vOutput:= TIdEncoderMIME.EncodeStream(vStream);
      finally
        vStream.Free;
        vBase64.Free;
      end;
      if not(vOutput = '') then
        Result:= vOutput
      else
        Result:= 'Erro';
    except
      on E:Exception do
        Result:= 'Erro';
    end;
  end else
    Result:= 'Erro Arquivo não encontrado.';
end;

class procedure TLib.Base64_Decode(ABase64: string; AStream: TMemoryStream);
var
  vDecoder: TIdDecoderMIME;
begin
  if not ABase64.IsEmpty then begin
    try
      try
        vDecoder:= TIdDecoderMIME.Create(nil);

        TIdDecoderMIME.DecodeStream(ABase64, AStream);
        AStream.Position:= 0;
      finally
        vDecoder.Free;
      end;
    except
      on E:Exception do
        raise Exception.Create(E.Message);
    end;
  end;
end;

{$ENDREGION}


{$REGION 'ENCRIPTAÇÃO'}
class function TLib.Crypt(Texto, Chave: String): String;
var
  x, y: Integer;
  NovaSenha: String;
begin
  for x := 1 to Length(Chave) do begin
    NovaSenha := '';
    for y := 1 to Length(Texto) do
      NovaSenha := NovaSenha + Chr((Ord(Chave[x]) xor Ord(Texto[y])));
    Texto := NovaSenha;
  end;
  Result := Texto;
end;

class function TLib.Crypto(aText: string): string;
begin
  Result:= Crypt(aText, 'DOUTORBY');
end;

class function TLib.Decrypto(aText: string): string;
begin
  Result:= Crypt(aText, 'DOUTORBY');
end;

class function TLib.Decrypto(aText, aChave: string): string;
begin
  Result:= Crypt(aText, aChave);
end;

class function TLib.CryptSameTextLength(Texto, Chave: String): String;
var
  x, y: Integer;
  NovaSenha: String;
begin
  for x := 1 to Length(Texto) do begin
    NovaSenha := '';
    for y := 1 to Length(Texto) do
      NovaSenha := NovaSenha + Chr((Ord(Chave[x]) xor Ord(Texto[y])));
    Texto := NovaSenha;
  end;
  Result := Texto;
end;
{$ENDREGION}

end.
