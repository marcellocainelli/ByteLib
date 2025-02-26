unit Byte.Controller.Stone.SmartTef;

interface

uses
  System.SysUtils, System.NetEncoding, RESTRequest4D, System.JSON;

type
  swType = (swNone, swDoutorByte, swRinocode);

  TRepostas = record
  public
   status:string;
    NSU: string;
    TipoTransacao: string;
    Bandeira: string;
    NomeAdquirente: string;
    CnpjAdquirente: string;
    erro:  string;
  end;

  IControllerStoneSmartTef = interface
    ['{D2A8A6D3-98F1-4C4D-AF9B-123456789ABC}']
    function swID(const AValue: swType): IControllerStoneSmartTef; overload;
    function swID: swType; overload;
    function EmpresaCNPJ(const AValue: string): IControllerStoneSmartTef; overload;
    function EmpresaCNPJ: String; overload;
    function Porta(const AValue: integer): IControllerStoneSmartTef; overload;
    function Porta: integer; overload;
    function Ip(const AValue: string): IControllerStoneSmartTef;
    function GerarChave: string;
    procedure SetChave(const Chave: string);

    function AtivarPos(out AErro: string): boolean;
    function EnviarPagamento(ATipoPagamento, AParcela, AValor, ACodPedido: string; out ADados :TRepostas; out AErro: string): boolean;
  end;

  TControllerStoneSmartTef = class(TInterfacedObject, IControllerStoneSmartTef)
  private
    FIdSw, FPorta: Integer;
    FEmpresaCNPJ, FIp, FSerial: string;
    const FPassword: string = '2123022025'; // Senha de verificação
    function Encrypt(const S: string): string;
    function Decrypt(const S: string): string;
    constructor Create;
    destructor Destroy; override;
  public
    class function New: IControllerStoneSmartTef;
    function swID(const AValue: swType): IControllerStoneSmartTef; overload;
    function swID: swType; overload;
    function EmpresaCNPJ(const AValue: string): IControllerStoneSmartTef; overload;
    function EmpresaCNPJ: String; overload;
    function Porta(const AValue: integer): IControllerStoneSmartTef; overload;
    function Porta: integer; overload;
    function Ip(const AValue: string): IControllerStoneSmartTef;
    function GerarChave: string;
    procedure SetChave(const Chave: string);

    function AtivarPos(out AErro: string): boolean;
    function EnviarPagamento(ATipoPagamento, AParcela, AValor, ACodPedido: string; out ADados :TRepostas; out AErro: string): boolean;
  end;

implementation

{ TStoneAtivacao }

class function TControllerStoneSmartTef.New: IControllerStoneSmartTef;
begin
  Result := Self.Create;
end;

constructor TControllerStoneSmartTef.Create;
begin
  FIdSw := -1;
  FPorta := 3000;
  FEmpresaCNPJ := '';
  FIp:= '';
  FSerial:= '';
end;

destructor TControllerStoneSmartTef.Destroy;
begin
  inherited;
end;

function TControllerStoneSmartTef.Encrypt(const S: string): string;
begin
  Result := TNetEncoding.Base64.Encode(S);
end;

function TControllerStoneSmartTef.Decrypt(const S: string): string;
begin
  Result := TNetEncoding.Base64.Decode(S);
end;

function TControllerStoneSmartTef.GerarChave: string;
var
  RawKey: string;
begin
  try
    if FIdSw = -1 then
      raise Exception.Create('Identificador da SW inválido');

    if FEmpresaCNPJ.IsEmpty then
      raise Exception.Create('CNPJ não informado');

    // Concatena as propriedades e a senha usando um delimitador (ex: ';')
    RawKey := Format('%d;%s;%d;%s', [FIdSw, FEmpresaCNPJ, FPorta, FPassword]);
    // Criptografa e retorna a chave gerada
    Result := Encrypt(RawKey);
    FSerial:= Result;
  except
    on E: Exception do
    begin
      raise Exception.Create('Erro: ' + E.Message);
    end;
  end;
end;

function TControllerStoneSmartTef.Ip(const AValue: string): IControllerStoneSmartTef;
begin
  Result:= Self;
  FIp:= AValue;
end;

procedure TControllerStoneSmartTef.SetChave(const Chave: string);
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
    if Length(Parts) = 4 then
    begin
      // Verifica se a senha está correta
      if Parts[3] <> FPassword then
        raise Exception.Create('Senha de verificação inválida.');

      FIdSw := StrToIntDef(Parts[0], 0);
      FEmpresaCNPJ := Parts[1];
      FPorta := StrToIntDef(Parts[2], 0);
    end
    else
    begin
      raise Exception.Create('Formato da chave inválido.');
    end;
  except
    on E: Exception do
    begin
      raise Exception.Create('Erro: ' + E.Message);
    end;
  end;
end;

function TControllerStoneSmartTef.swID: swType;
begin
  case FIdSw of
    1: Result := swDoutorByte;
    2: Result := swRinocode;
  else
    Result := swNone;
  end;
end;

function TControllerStoneSmartTef.swID(const AValue: swType): IControllerStoneSmartTef;
begin
  Result := Self;
  case AValue of
    swDoutorByte: FIdSw := 1;
    swRinocode: FIdSw := 2;
  else
    FIdSw := -1;
  end;
end;

function TControllerStoneSmartTef.EmpresaCNPJ: String;
begin
  Result := FEmpresaCNPJ;
end;

function TControllerStoneSmartTef.EmpresaCNPJ(const AValue: string): IControllerStoneSmartTef;
begin
  Result := Self;
  FEmpresaCNPJ := AValue;
end;

function TControllerStoneSmartTef.Porta: integer;
begin
  Result := FPorta;
end;

function TControllerStoneSmartTef.Porta(const AValue: integer): IControllerStoneSmartTef;
begin
  Result := Self;
  FPorta := AValue;
end;

function TControllerStoneSmartTef.EnviarPagamento(ATipoPagamento, AParcela, AValor, ACodPedido: string; out ADados: TRepostas; out AErro: string): boolean;
var
  vResp: IResponse;
  vObj, vObjR : TJSONObject;
  vMessageValue : TJSONValue;
begin
  Result := false;
  try
    vResp := TRequest.New.BaseURL('http:\\' + FIp + ':' + FPorta.ToString)
                        .Resource('Pagamento')
                        .AddHeader('chave', FSerial,[poDoNotEncode])
                        .AddHeader('tipopagamento', ATipoPagamento,[poDoNotEncode])
                        .AddHeader('valor', AValor,[poDoNotEncode])
                        .AddHeader('parcelas', AParcela,[poDoNotEncode])
                        .AddHeader('pedido', ACodPedido,[poDoNotEncode])
                        .Accept('application/json')
                        .Timeout(120000)
                        .Post;

    case vResp.StatusCode of
      200: begin
        vObj := TJSONObject.ParseJSONValue(vResp.Content) as TJSONObject;

        if Assigned(vObj.GetValue('status')) then
            ADados.status := vObj.GetValue('status').Value
        else
          ADados.status := 'status não encontrado no JSON';

         vMessageValue := vObj.GetValue('message');

        if Assigned(vMessageValue) then
        begin
          vObjR := TJSONObject.ParseJSONValue(vMessageValue.ToString) as TJSONObject;

          if Assigned(vObjR) then
          try
            if Assigned(vObjR.GetValue('NSU')) then
             ADados.NSU :=  vObjR.GetValue('NSU').Value;

            if Assigned(vObjR.GetValue('TipoTransacao')) then
             ADados.TipoTransacao := vObjR.GetValue('TipoTransacao').Value;

            if Assigned(vObjR.GetValue('Bandeira')) then
             ADados.Bandeira :=  vObjR.GetValue('Bandeira').Value;

            if Assigned(vObjR.GetValue('NomeAdquirente')) then
             ADados.NomeAdquirente :=  vObjR.GetValue('NomeAdquirente').Value;

            if Assigned(vObjR.GetValue('CnpjAdquirente')) then
             ADados.CnpjAdquirente := vObjR.GetValue('CnpjAdquirente').Value;
          finally
            vObjR.Free;
          end else begin
            ADados.erro :=   'Mensagem JSON inválida';
          end;
        end;

        Result := true;
      end;

      400: begin
        vObjR := TJSONObject.ParseJSONValue(vResp.Content) as TJSONObject;
        try
          if Assigned(vobjR.GetValue('status')) then
            AErro := vobjR.GetValue('status').Value;
          Result := False;
        finally
          vObjR.Free;
        end;

      end;

      500: begin
        AErro :=  'Erro não catalogado no servidor';
        Result := False;
      end;

      else begin
        Result := False;
      end;
    end;
  except
    on e: exception do begin
      Result := false;

      AErro := 'Erro: ' + e.Message;

      if vResp.StatusCode = 0 then
       AErro := 'Não foi possível obter resposta do servidor!'+ e.Message;
    end;
  end;
end;

function TControllerStoneSmartTef.AtivarPos(out AErro: string): boolean;
var
  vResp: IResponse;
begin
  Result := false;
  try
    vResp := TRequest.New.BaseURL('http:\\'+ FIp + ':' + FPorta.ToString)
                        .Resource('ativar')
                        .AddHeader('chave', FSerial,[poDoNotEncode])
                        .Accept('application/json')
                        .Timeout(10000)
                        .post;

    case vResp.StatusCode of
      200: begin
        Result := true;
      end;

      400: begin
        AErro  := vResp.Content;
        Result := False;
      end;

      else begin
        Result := False;
      end;
    end;
  except
    on e: exception do begin
      Result := false;

      AErro := 'Erro: ' + e.Message;

      if vResp.StatusCode = 0 then
       AErro := 'Não foi possível obter resposta do servidor!';
    end;
  end;
end;

end.
