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

  IdCoderMIME,

  ShellAPI,

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

  TLib = class
    private
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

      {Funções de formatação}
      class function SomenteNumero(const AValue: string): string;
      class function PoeZeros(Valor: String; Tamanho,Decimais:Integer): String;

      {Funções de validação}
      class function IsCNPJ(AValue: string): boolean;
      class function IsCPF(AValue: string): boolean;

      {FUNÇÕES BASE64}
      class function Base64_Encode(AFile: string): string;
      class procedure Base64_Decode(ABase64: string; AStream: TMemoryStream);
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
        if Assigned(AOnComplete) then begin
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

class procedure TLib.VCL_OpenPDF(AFile: TFileName; ATypeForm: Integer);
var
  vDir: PChar;
begin
  GetMem(vDir, 256);
  StrPCopy(vDir, AFile);
  ShellExecute(0, nil, PChar(AFile), nil, vDir, ATypeForm);
  FreeMem(vDir, 256);
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
end.
