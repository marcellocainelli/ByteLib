unit Byte.Controller.Logme_v1;

interface

uses
  System.Classes, System.SysUtils, System.JSON, RESTRequest4D, System.Generics.Collections;

const
  C_URL = 'http://api.logmetributos.com.br';

type
  TItem = record
    EAN: string;
    DESCRICAO: string;
    REGIME_TRIBUTARIO_REMETENTE: integer;
    UF_ORIGEM: string;
    UF_DESTINO: string;
    NCM: string;
    CFOP: string;
    CEST: string;
    ALIQ_ICMS: double;
    RED_BASE_CALCULO_ICMS: double;
    CODIGO_CST: string;
    CODIGO_CLASSTRIB: string;
    COD_BENEFICIO_FISCAL: string;
    RED_BASE_CALCULO_ICMS_ST: double;
    ICMS_ST_ALIQUOTA_INTERNA: double;
    MVA: double;
    IPI: integer;
    CST_IPI: integer;
    PIS_CST: string;
    ALIQUOTA_PIS: double;
    COFINS_CST: string;
    ALIQUOTA_COFINS: double;
    CST_IS: string;
    CST_IBS: string;
    CST_CBS: string;
    CODIGO_CLASSTRIB_IS: string;
    CODIGO_CLASSTRIB_CBS: string;
    CODIGO_CLASSTRIB_IBS: string;
    REDUCAO_IBS: double;
    REDUCAO_CBS: double;
    CONDICAO: integer;
  end;


  iLogme = interface
  ['{A2D6A434-1EBC-475B-8F9C-37534F8D120C}']
    function Sucesso: Boolean;
    function Mensagem: String;
    function TokenApi(AValue: String): iLogme;
    function UfDestino(AValue: String): iLogme;
    function TipoDestinatario(AValue: String): iLogme;

    function ConsultaProdutos: iLogme;
    function ConsultaLote: iLogme;
    function AddProduto(AEan, ADescricao: String): iLogme;
    function ListaProdutos: TList<TItem>;
  end;

  TLogme = class(TInterfacedObject, iLogme)
    private
      FSucesso: Boolean;
      FToken, FMsg, FUfDestino, FTipoDestinatario: String;
      FBodyObject: TJSONObject;
      FProdutosArray: TJSONArray;
      FListaItens: TList<TItem>;
      constructor Create;
      destructor Destroy; override;
      function ConsultaProduto_MontaReqBody: String;
      function ConsultaLote_MontaReqBody: String;
      function ConsultaProduto_MontaListaItens: boolean;
      function ConsultaLote_MontaListaItens(ARetorno: string): boolean;
      procedure SetReqResult(ASucesso: Boolean; AMensagem: String);
    public
      class function New: iLogme;
      function Sucesso: Boolean;
      function Mensagem: String;
      function TokenApi(AValue: String): iLogme;
      function UfDestino(AValue: String): iLogme;
      function TipoDestinatario(AValue: String): iLogme;

      function ConsultaProdutos: iLogme;
      function ConsultaLote: iLogme;
      function AddProduto(AEan, ADescricao: String): iLogme;
      function ListaProdutos: TList<TItem>;
  end;

implementation

{ TLogme }

class function TLogme.New: iLogme;
begin
  Result:= Self.Create;
end;

constructor TLogme.Create;
begin
  FBodyObject:= TJSONObject.Create;
  FListaItens := TList<TItem>.Create;
  FUfDestino:= 'SP';
  FTipoDestinatario:= '1';
end;

destructor TLogme.Destroy;
begin
  if Assigned(FBodyObject) then
    FBodyObject.Free;
  FListaItens.Free;
  inherited;
end;

function TLogme.ListaProdutos: TList<TItem>;
begin
  Result:= FListaItens;
end;

function TLogme.Mensagem: String;
begin
  Result:= FMsg;
end;

function TLogme.ConsultaProduto_MontaReqBody: String;
begin
  FBodyObject.AddPair('produtos', FProdutosArray);
  Result:= FBodyObject.ToString;
end;

function TLogme.ConsultaLote_MontaReqBody: String;
begin
  FBodyObject.AddPair('tipo_destinatario', FTipoDestinatario);
  FBodyObject.AddPair('uf_destino', FUfDestino);
  FBodyObject.AddPair('produtos', FProdutosArray);
  Result:= FBodyObject.ToString;
end;

procedure TLogme.SetReqResult(ASucesso: Boolean; AMensagem: String);
begin
  FSucesso:= ASucesso;
  FMsg:= AMensagem;
end;

function TLogme.Sucesso: Boolean;
begin
  Result:= FSucesso;
end;

function TLogme.TipoDestinatario(AValue: String): iLogme;
begin
  Result:= Self;
  FTipoDestinatario:= AValue;
end;

function TLogme.TokenApi(AValue: String): iLogme;
begin
  Result:= Self;
  FToken:= AValue;
end;

function TLogme.UfDestino(AValue: String): iLogme;
begin
  Result:= Self;
  FUfDestino:= AValue;
end;

function TLogme.ConsultaProdutos: iLogme;
var
  vResp: IResponse;
begin
  if FToken.IsEmpty then begin
    SetReqResult(False, 'O token informado é inválido!');
    Exit;
  end;

  try
    vResp:= TRequest.New.BaseURL(C_URL)
          .Timeout(120000)
          .Resource('produtos/consultaProduto')
          .ContentType('application/json')
          .AddBody(ConsultaProduto_MontaReqBody)
          .TokenBearer(FToken)
          .Get;

//    if vResp.StatusCode = 200 then
//      PreencheDadosVeiculo(vResp.Content)
//    else
//      raise Exception.Create(vResp.Content);
    SetReqResult(True, 'Dados encontrados');
  except
    on E:Exception do begin
      SetReqResult(False, 'Erro:' + sLineBreak + E.Message);
    end;
  end;
end;

function TLogme.ConsultaLote: iLogme;
var
  vResp: IResponse;
begin
  if FToken.IsEmpty then begin
    SetReqResult(False, 'O token informado é inválido!');
    Exit;
  end;

  try
    vResp:= TRequest.New.BaseURL(C_URL)
          .Timeout(240000)
          .Resource('produtos/consultaLote')
          .ContentType('application/json')
          .AddBody(ConsultaLote_MontaReqBody)
          .TokenBearer(FToken)
          .Get;

    if vResp.StatusCode = 200 then begin
      if not ConsultaLote_MontaListaItens(vResp.Content) then
        raise Exception.Create(vResp.Content);
    end else
      raise Exception.Create(vResp.Content);
    SetReqResult(True, 'Dados encontrados');
  except
    on E:Exception do begin
      SetReqResult(False, 'Erro:' + sLineBreak + E.Message);
    end;
  end;
end;

function TLogme.AddProduto(AEan, ADescricao: String): iLogme;
var
  LProduto: TJSONObject;
begin
  Result := Self;
  if not Assigned(FProdutosArray) then
    FProdutosArray:= TJSONArray.Create;
  LProduto := TJSONObject.Create;
  LProduto.AddPair('ean', AEan);
  LProduto.AddPair('descricao', ADescricao);
  FProdutosArray.AddElement(LProduto);
end;

function TLogme.ConsultaProduto_MontaListaItens: boolean;
begin

end;

function TLogme.ConsultaLote_MontaListaItens(ARetorno: string): boolean;
var
  vJSONValue: TJSONValue;
  vJSONObject, vItemObject: TJSONObject;
  vJSONArray: TJSONArray;
  vItem: TItem;
  I: Integer;
  vMensagem: String;
begin
  Result:= False;
  // Limpa a lista existente
  FListaItens.Clear;
  vJSONValue := TJSONObject.ParseJSONValue(ARetorno);
  try
    if not Assigned(vJSONValue) then
      Exit;
    if not (vJSONValue is TJSONObject) then
      Exit;
    vJSONObject := TJSONObject(vJSONValue);
    // Captura o success
    Result := vJSONObject.GetValue<Boolean>('success');
    // Se não teve sucesso, não processa os itens
    if not Result then
      Exit;
    // Obtém o array data
    vJSONArray := vJSONObject.GetValue<TJSONArray>('data');
    if not Assigned(vJSONArray) then
      Exit;
    // Percorre os itens
    for I := 0 to vJSONArray.Count - 1 do begin
      vMensagem:= '';
      vItemObject := vJSONArray.Items[I] as TJSONObject;
      vItem.EAN := vItemObject.GetValue<string>('ean');
      vItem.CONDICAO:= 1;
      if vItemObject.TryGetValue<string>('mensagem', vMensagem) then begin
        if vMensagem.Contains('Aguarde definicao da regra de imposto') then
          vItem.CONDICAO:= 2
        else
          vItem.CONDICAO:= 3;
      end else begin
        vItem.DESCRICAO := vItemObject.GetValue<string>('descrição');
        vItem.REGIME_TRIBUTARIO_REMETENTE := vItemObject.GetValue<integer>('regime_tributario_remetente');
        vItem.UF_ORIGEM := vItemObject.GetValue<string>('uf_origem');
        vItem.UF_DESTINO := vItemObject.GetValue<string>('uf_destino');
        vItem.NCM := vItemObject.GetValue<string>('ncm');
        vItem.CFOP := vItemObject.GetValue<string>('cfop');
        vItem.CEST := vItemObject.GetValue<string>('cest');
        vItem.ALIQ_ICMS := StrToCurrDef(vItemObject.GetValue<string>('aliquota_icms'), 0);
        vItem.RED_BASE_CALCULO_ICMS := StrToCurrDef(vItemObject.GetValue<string>('red_base_de_calculo_icms'), 0);
        vItem.CODIGO_CST := vItemObject.GetValue<string>('cst');
        if Length(vItem.CODIGO_CST) = 2 then
          vItem.CODIGO_CST:= '0'+ vItem.CODIGO_CST;
        vItem.CODIGO_CLASSTRIB := vItemObject.GetValue<string>('codigo_classtrib');
        vItem.COD_BENEFICIO_FISCAL := vItemObject.GetValue<string>('cod_beneficio_fiscal');
        vItem.RED_BASE_CALCULO_ICMS_ST := StrToCurrDef(vItemObject.GetValue<string>('aliquota_icms'), 0);
        vItem.ICMS_ST_ALIQUOTA_INTERNA := StrToCurrDef(vItemObject.GetValue<string>('icms_st_aliquota_interna'), 0);
  //      vItem.MVA := vItemObject.GetValue<double>('mva');
        vItem.IPI := StrToIntDef(vItemObject.GetValue<string>('ipi'), 0);
        vItem.CST_IPI := StrToIntDef(vItemObject.GetValue<string>('cst_ipi'), 0);
        vItem.PIS_CST := vItemObject.GetValue<string>('pis_cst');
        vItem.ALIQUOTA_PIS := StrToCurrDef(vItemObject.GetValue<string>('aliquota_pis'), 0);
        vItem.COFINS_CST := vItemObject.GetValue<string>('cofins_cst');
        vItem.ALIQUOTA_COFINS := StrToCurrDef(vItemObject.GetValue<string>('aliquota_cofins'), 0);
        vItem.CST_IS := vItemObject.GetValue<string>('cst_is');
        vItem.CST_IBS := vItemObject.GetValue<string>('cst_ibs');
        vItem.CST_CBS := vItemObject.GetValue<string>('cst_cbs');
        vItem.CODIGO_CLASSTRIB_IS := vItemObject.GetValue<string>('codigo_classtrib_is');
        vItem.CODIGO_CLASSTRIB_CBS := vItemObject.GetValue<string>('codigo_classtrib_cbs');
        vItem.CODIGO_CLASSTRIB_IBS := vItemObject.GetValue<string>('codigo_classtrib_ibs');
        vItem.REDUCAO_IBS := StrToCurrDef(vItemObject.GetValue<string>('reducao_ibs'), 0);
        vItem.REDUCAO_CBS := StrToCurrDef(vItemObject.GetValue<string>('reducao_cbs'), 0);
      end;
      FListaItens.Add(vItem);
    end;
  finally
    vJSONValue.Free;
  end;
end;

end.
