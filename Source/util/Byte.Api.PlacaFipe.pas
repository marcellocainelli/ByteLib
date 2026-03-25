unit Byte.Api.PlacaFipe;

interface

uses
  System.Classes, System.SysUtils, System.JSON, RESTRequest4D;

const
  C_URL = 'https://api.placafipe.com.br';

type
  iPlacaFipe = interface
  ['{7B499205-2020-4BB6-8DBA-A05B920D644D}']
    function Sucesso: Boolean;
    function Mensagem: String;
    function TokenApi(AValue: String): iPlacaFipe;

    function Veiculo_Marca: String;
    function Veiculo_Modelo: String;
    function Veiculo_Ano: String;
    function Veiculo_Ano_Modelo: String;
    function Veiculo_Cor: String;
    function Veiculo_Chassi: String;
    function Veiculo_Municipio: String;
    function Veiculo_UF: String;
    function Veiculo_Cilindradas: String;
    function Veiculo_Combustivel: String;

    function GetDadosVeiculo(APlaca: String): iPlacaFipe;
  end;

  TPlacaFipe = class(TInterfacedObject, iPlacaFipe)
    private
      FSucesso: Boolean;
      FToken, FMsg: String;
      FMarca, FModelo, FAno, FAnoModelo, FCor, FChassi, FMunicipio, FUF, FCilindradas, FCombustivel: String;
      constructor Create;
      destructor Destroy; override;
      function MontaReqBody(APlaca: String): String;
      procedure SetReqResult(ASucesso: Boolean; AMensagem: String);
      procedure PreencheDadosVeiculo(AJson: String);
    public
      class function New: iPlacaFipe;
      function Sucesso: Boolean;
      function Mensagem: String;
      function TokenApi(AValue: String): iPlacaFipe;

      function Veiculo_Marca: String;
      function Veiculo_Modelo: String;
      function Veiculo_Ano: String;
      function Veiculo_Ano_Modelo: String;
      function Veiculo_Cor: String;
      function Veiculo_Chassi: String;
      function Veiculo_Municipio: String;
      function Veiculo_UF: String;
      function Veiculo_Cilindradas: String;
      function Veiculo_Combustivel: String;

      function GetDadosVeiculo(APlaca: String): iPlacaFipe;
  end;

implementation

{ TPlacaFipe }

class function TPlacaFipe.New: iPlacaFipe;
begin
  Result:= Self.Create;
end;

constructor TPlacaFipe.Create;
begin

end;

destructor TPlacaFipe.Destroy;
begin

  inherited;
end;

function TPlacaFipe.GetDadosVeiculo(APlaca: String): iPlacaFipe;
var
  vResp: IResponse;
begin
  Result:= Self;
  if (APlaca = '') or (Length(APlaca) < 7) then begin
    SetReqResult(False, 'A placa informada é inválida!');
    Exit;
  end;

  if FToken.IsEmpty then begin
    SetReqResult(False, 'O token informado é inválido!');
    Exit;
  end;


  try
    vResp:= TRequest.New.BaseURL(C_URL)
          .Timeout(120000)
          .Resource('getplaca')
          .ContentType('application/json')
          .AcceptEncoding('UTF-8')
          .AddBody(MontaReqBody(APlaca))
          .Post;

    if vResp.StatusCode = 200 then
      PreencheDadosVeiculo(vResp.Content)
    else
      raise Exception.Create(vResp.Content);
    SetReqResult(True, 'Dados encontrados');
  except
    on E:Exception do begin
      SetReqResult(False, 'Erro:' + sLineBreak + E.Message);
    end;
  end;
end;

procedure TPlacaFipe.PreencheDadosVeiculo(AJson: String);
var
  vJsonObj, vInfoObj: TJSONObject;
  vCodigo: integer;
begin
  vJsonObj := TJSONObject.ParseJSONValue(AJson) as TJSONObject;
  try
    vJsonObj.TryGetValue<integer>('codigo', vCodigo);
    if vCodigo <> 1 then
      raise Exception.Create(AJson);
    vInfoObj := vJsonObj.GetValue<TJSONObject>('informacoes_veiculo');
    vInfoObj.TryGetValue('marca', FMarca);
    vInfoObj.TryGetValue('modelo', FModelo);
    vInfoObj.TryGetValue('ano', FAno);
    vInfoObj.TryGetValue('ano_modelo', FAnoModelo);
    vInfoObj.TryGetValue('cor', FCor);
    vInfoObj.TryGetValue('chassi', FChassi);
    vInfoObj.TryGetValue('municipio', FMunicipio);
    vInfoObj.TryGetValue('uf', FUF);
    vInfoObj.TryGetValue('cilindradas', FCilindradas);
    vInfoObj.TryGetValue('combustivel', FCombustivel);
  finally
    vJsonObj.Free;
  end;
end;

function TPlacaFipe.Mensagem: String;
begin
  Result:= FMsg;
end;

function TPlacaFipe.Sucesso: Boolean;
begin
  Result:= FSucesso;
end;

function TPlacaFipe.TokenApi(AValue: String): iPlacaFipe;
begin
  Result:= Self;
  FToken:= AValue;
end;

function TPlacaFipe.Veiculo_Ano: String;
begin
  Result:= FAno;
end;

function TPlacaFipe.Veiculo_Ano_Modelo: String;
begin
  Result:= FAnoModelo;
end;

function TPlacaFipe.Veiculo_Chassi: String;
begin
  Result:= FChassi;
end;

function TPlacaFipe.Veiculo_Cilindradas: String;
begin
  Result:= FCilindradas;
end;

function TPlacaFipe.Veiculo_Combustivel: String;
begin
  Result:= FCombustivel;
end;

function TPlacaFipe.Veiculo_Cor: String;
begin
  Result:= FCor;
end;

function TPlacaFipe.Veiculo_Marca: String;
begin
  Result:= FMarca;
end;

function TPlacaFipe.Veiculo_Modelo: String;
begin
  Result:= FModelo;
end;

function TPlacaFipe.Veiculo_Municipio: String;
begin
  Result:= FMunicipio;
end;

function TPlacaFipe.Veiculo_UF: String;
begin
  Result:= FUF;
end;

procedure TPlacaFipe.SetReqResult(ASucesso: Boolean; AMensagem: String);
begin
  FSucesso:= ASucesso;
  FMsg:= AMensagem;
end;

function TPlacaFipe.MontaReqBody(APlaca: String): String;
var
  vJsonObject: TJSONObject;
begin
  Result:= '';
  vJsonObject:= TJSONObject.Create;
  try
    vJsonObject.AddPair('token', FToken);
    vJsonObject.AddPair('placa', APlaca);
    Result:= vJsonObject.ToString;
  finally
    vJsonObject.Free;
  end;
end;

end.
