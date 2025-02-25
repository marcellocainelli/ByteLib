unit Stone.AtivacaoPos;

interface

uses
  System.SysUtils, System.NetEncoding;

type
  swType = (swDoutorByte, swRinocode);

  IStoneAtivacao = interface
    ['{D2A8A6D3-98F1-4C4D-AF9B-123456789ABC}']
    function swID(const AValue: swType): IStoneAtivacao; overload;
    function swID: swType; overload;
    function EmpresaCNPJ(const AValue: string): IStoneAtivacao; overload;
    function EmpresaCNPJ: String; overload;
    function Porta(const AValue: integer): IStoneAtivacao; overload;
    function Porta: integer; overload;
    function GerarChave: string;
    procedure SetChave(const Chave: string);
  end;

  TStoneAtivacao = class(TInterfacedObject, IStoneAtivacao)
  private
    FIdSw, FPorta: Integer;
    FEmpresaCNPJ: string;
    function Encrypt(const S: string): string;
    function Decrypt(const S: string): string;
    constructor Create;
    destructor Destroy; override;
  public
    class function New: IStoneAtivacao;
    function swID(const AValue: swType): IStoneAtivacao; overload;
    function swID: swType; overload;
    function EmpresaCNPJ(const AValue: string): IStoneAtivacao; overload;
    function EmpresaCNPJ: String; overload;
    function Porta(const AValue: integer): IStoneAtivacao; overload;
    function Porta: integer; overload;
    function GerarChave: string;
    procedure SetChave(const Chave: string);
  end;

implementation

{ TStoneAtivacao }

class function TStoneAtivacao.New: IStoneAtivacao;
begin
  Result:= Self.Create;
end;

constructor TStoneAtivacao.Create;
begin
  FIdSw:= -1;
  FPorta:= 3000;
  FEmpresaCNPJ:= '';
end;

destructor TStoneAtivacao.Destroy;
begin

  inherited;
end;

function TStoneAtivacao.Encrypt(const S: string): string;
begin
  Result := TNetEncoding.Base64.Encode(S);
end;

function TStoneAtivacao.Decrypt(const S: string): string;
begin
  Result := TNetEncoding.Base64.Decode(S);
end;

function TStoneAtivacao.GerarChave: string;
var
  RawKey: string;
begin
  try
    if FIdSw = -1 then
      raise Exception.Create('Identificador da SW inválido');

    if FEmpresaCNPJ.IsEmpty then
      raise Exception.Create('CNPJ não informado');
  
    // Concatena as propriedades usando um delimitador (ex: ';')
    RawKey := Format('%d;%s;%d', [FIdSw, FEmpresaCNPJ, FPorta]);
    // Criptografa e retorna a chave gerada
    Result := Encrypt(RawKey);
  except
    on E:Exception do begin
      raise Exception.Create('Erro: ' + E.Message);
    end;
  end;
end;

procedure TStoneAtivacao.SetChave(const Chave: string);
var
  RawKey: string;
  Parts: TArray<string>;
begin
  try
    if Chave.IsEmpty then
      raise Exception.Create('A chave não pode ser vazia.');
          
    // Descriptografa a chave recebida
    RawKey := Decrypt(Chave);
    // Divide a string nos delimitadores para extrair as propriedades
    Parts := RawKey.Split([';']);
    if Length(Parts) = 3 then begin
      FIdSw := StrToIntDef(Parts[0], 0);
      FEmpresaCNPJ := Parts[1];
      FPorta := StrToIntDef(Parts[2], 0);
    end;
  except
    on E:Exception do begin
      raise Exception.Create('Erro: ' + E.Message);
    end;
  end;
end;

function TStoneAtivacao.swID: swType;
begin
  case FIdSw of
    1: Result:= swDoutorByte;
    2: Result:= swRinocode;
  end;
end;

function TStoneAtivacao.swID(const AValue: swType): IStoneAtivacao;
begin
  Result:= Self;
  case AValue of
    swDoutorByte: FIdSw:= 1;
    swRinocode: FIdSw:= 2;
  end;
end;

function TStoneAtivacao.EmpresaCNPJ: String;
begin
  Result:= FEmpresaCNPJ;
end;

function TStoneAtivacao.EmpresaCNPJ(const AValue: string): IStoneAtivacao;
begin
  Result:= Self;
  FEmpresaCNPJ:= AValue;
end;

function TStoneAtivacao.Porta: integer;
begin
  Result:= FPorta;
end;

function TStoneAtivacao.Porta(const AValue: integer): IStoneAtivacao;
begin
  Result:= Self;
  FPorta:= AValue;
end;

end.

