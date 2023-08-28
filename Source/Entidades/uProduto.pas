unit uProduto;
interface
uses
  System.SysUtils,
  StrUtils,
  uDmFuncoes,
  Data.DB,
  Model.Entidade.Interfaces;
  Type
  TProduto = class(TInterfacedObject, iEntidadeProduto)
    private
      FEntidadeBase: iEntidadeBase<iEntidadeProduto>;
      FValidaDepto: Boolean;
      FCodDeptoUsuario: integer;
      FTipoConsulta: string;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidadeProduto;
      function EntidadeBase: iEntidadeBase<iEntidadeProduto>;
      function Consulta(Value: TDataSource = nil): iEntidadeProduto;
      function InicializaDataSource(Value: TDataSource = nil): iEntidadeProduto;
      function ValidaDepto(pValue: boolean): iEntidadeProduto; overload;
      function ValidaDepto: boolean; overload;
      function CodDeptoUsuario(pValue: Integer ): iEntidadeProduto; overload;
      function CodDeptoUsuario: Integer ; overload;
      function TipoConsulta(pValue: String): iEntidadeProduto; overload;
      function TipoConsulta: String ; overload;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
      procedure SelecionaSQLConsulta;
  end;
implementation
uses
  uEntidadeBase;
{ TProduto }
constructor TProduto.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidadeProduto>.New(Self);
  FTipoConsulta:= 'Consulta';
end;
destructor TProduto.Destroy;
begin
  inherited;
end;
class function TProduto.New: iEntidadeProduto;
begin
  Result:= Self.Create;
end;
function TProduto.EntidadeBase: iEntidadeBase<iEntidadeProduto>;
begin
  Result:= FEntidadeBase;
end;
procedure TProduto.SelecionaSQLConsulta;
begin
  {$IFDEF APP}
  case AnsiIndexStr(TipoConsulta, ['Consulta', 'Filtra']) of
  0: FEntidadeBase.TextoSQL(
            'Select P.*, EF.QUANTIDADE From PRODUTOS P ' +
            'Left Join ESTOQUEFILIAL EF on (EF.COD_PROD = P.COD_PROD and EF.COD_FILIAL = :pFilial) ' +
            'where (1=1)');
  1: FEntidadeBase.TextoSQL(
            'Select P.*, EF.QUANTIDADE From PRODUTOS P ' +
            'Left Join ESTOQUEFILIAL EF on (EF.COD_PROD = P.COD_PROD and EF.COD_FILIAL = :pFilial) ' +
            'where (1=1)' +
            'and ((COD_MARCA = :mCOD_MARCA) or (:mCOD_MARCA = -1))');
            //'and ((P.COD_MARCA1 = :mCOD_MARCA1) or (:mCOD_MARCA1 = -1)) ' +
            //'and ((P.COD_SUBGRUPO = :mCOD_SUBGRUPO) or (:mCOD_SUBGRUPO = -1)) ' +
            //'and ((P.COD_FORNEC = :mCOD_FORNEC) or (:mCOD_FORNEC = -1))');
  end;
  {$ELSE}
  case AnsiIndexStr(TipoConsulta, ['Consulta', 'Filtra', 'Cadastro', 'PDV']) of
  0: FEntidadeBase.TextoSQL(
            'Select P.COD_PROD, P.COD_PROD as CODIGO, P.NOME_PROD, P.UNIDADE as UN, P.PRECO_VEND as PRECO, ' +
            'P.PRECO_PRAZ as PRAZO, E.QUANTIDADE, P.PESO, P.COD_BARRA, P.REFERENCIA, P.LOCAL, P.DETALHE, ' +
            'M1.DESCRICAO, PP.PRECO as PROMOCAO, PP.QTDD_MINIMA, P.COMPLEMENTO, P.COD_MARCA, P.ICMS, ' +
            'P.C_MEDIO,P.MARGEM,P.QUANT_MIN,P.ETIQUETA,P.REDBASECALC,P.SITTRIBUTARIA, ' +
            'P.ISS,P.COD_FORNEC,P.PRECOCOMPRA,P.IPI,P.FRETE,P.FINANCEIRO,P.BALANCA,P.BALANCATECLA,P.IMAGEM,P.DTATUALIZACAO, ' +
            'P.COD_MARCA1,P.COD_SIMILAR,P.STATUS,P.LOCAL,P.SERIAL,P.MONOFASICO,P.SUBSTITUICAO, ' +
            'P.PSICOTROPICO,P.CLASFISCAL,P.TIPO,P.DESCONTO,P.COD_BYTE,P.PESAVEL,P.BEBIDAALCOOLICA,P.COD_TAMANHO,P.DTCADASTRO, ' +
            'P.VALIDADE,P.FLG_GRADE,P.TIPO_ITEM,P.CEST,P.COD_SUBGRUPO,P.COD_CAIXA,P.DTULTIMAVENDA,P.FLG_LOTE ' +
            'From PRODUTOS P ' +
            'Join MARCAS M on (M.CODIGO = P.COD_MARCA) ' +
            'Left Join ESTOQUEFILIAL E on (E.COD_PROD = P.COD_PROD and E.COD_FILIAL = :mCodFilial) ' +
            'Left Join MARCAS1 M1 on (M1.CODIGO = P.COD_MARCA1) ' +
            'Left Join PRODUTOS_PROMOCAO PP on ((PP.COD_PROD = P.COD_PROD) and (current_date >= PP.dtinicio and current_date <= PP.dtfim)) ' +
            'where (1=1)');
  1: FEntidadeBase.TextoSQL(
            'Select P.*, P.PRECO_VEND as PRECO, P.PRECO_PRAZ as PRAZO, B.QUANTIDADE ' + //, B.QUANTIDADE as ESTOQUE ' +
            'From PRODUTOS P ' +
            'Left Join ESTOQUEFILIAL B on (P.COD_PROD = B.COD_PROD and B.COD_FILIAL = :mCodFilial)' +
            'Where (1 = 1) ' +
            'and ((P.COD_MARCA = :mCOD_MARCA) or (:mCOD_MARCA = -1)) ' +
            'and ((P.COD_MARCA1 = :mCOD_MARCA1) or (:mCOD_MARCA1 = -1)) ' +
            'and ((P.COD_SUBGRUPO = :mCOD_SUBGRUPO) or (:mCOD_SUBGRUPO = -1)) ' +
            'and ((P.COD_FORNEC = :mCOD_FORNEC) or (:mCOD_FORNEC = -1))');
  2: FEntidadeBase.TextoSQL(
            'Select P.*, EF.QUANTIDADE ' +
            'From PRODUTOS P ' +
            'Left Join ESTOQUEFILIAL EF on (EF.COD_PROD = P.COD_PROD and EF.COD_FILIAL = :mCodFilial) ' +
            'where (1=1) ');
  3: FEntidadeBase.TextoSQL(
            'Select P.COD_PROD, P.COD_PROD as CODIGO, P.NOME_PROD, P.UNIDADE as UN, P.PRECO_VEND as PRECO, ' +
            'P.PRECO_PRAZ as PRAZO, E.QUANTIDADE, P.PESO, P.COD_BARRA, P.REFERENCIA, P.LOCAL, P.DETALHE, ' +
            'M.DESCRICAO as GRUPO, M1.DESCRICAO as MARCA, SUBG.DESCRICAO as SUBGRUPO, PP.PRECO as PROMOCAO, PP.QTDD_MINIMA, P.COMPLEMENTO, P.COD_MARCA, P.ICMS, ' +
            'P.C_MEDIO,P.MARGEM,P.SITTRIBUTARIA, ' +
            'P.COD_FORNEC,P.PRECOCOMPRA,P.BALANCA,P.IMAGEM, ' +
            'P.CLASFISCAL,P.DESCONTO,P.COD_TAMANHO, ' +
            'P.VALIDADE,P.FLG_GRADE,P.CEST ' +
            'From PRODUTOS P ' +
            'Join MARCAS M on (M.CODIGO = P.COD_MARCA) ' +
            'Left Join ESTOQUEFILIAL E on (E.COD_PROD = P.COD_PROD and E.COD_FILIAL = :mCodFilial) ' +
            'Left Join MARCAS1 M1 on (M1.CODIGO = P.COD_MARCA1) ' +
            'Left Join SUBGRUPOS SUBG on (SUBG.CODIGO = P.COD_SUBGRUPO) ' +
            'Left Join PRODUTOS_PROMOCAO PP on ((PP.COD_PROD = P.COD_PROD) and (current_date >= PP.dtinicio and current_date <= PP.dtfim)) ' +
            'where (1=1) and P.STATUS = ''A''');
  end;
  {$ENDIF}
end;
function TProduto.Consulta(Value: TDataSource): iEntidadeProduto;
var
  vTextoSQL: string;
  vNumeroAux: Int64;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  vTextoSQL:= FEntidadeBase.TextoSql;
  {$IFDEF APP}
  if FEntidadeBase.RegraPesquisa = 'Contendo' then
    FEntidadeBase.RegraPesquisa('Containing')
  else if FEntidadeBase.RegraPesquisa = 'Início do texto' then
    FEntidadeBase.RegraPesquisa('Starting With');
  Case FEntidadeBase.TipoPesquisa of
    //busca por código/cód barras/descrição
    0: begin
        if (TryStrToInt64(FEntidadeBase.TextoPesquisa, vNumeroAux)) then begin
          if Length(FEntidadeBase.TextoPesquisa) < 12 then
            //busca por código
            vTextoSQL:= vTextoSQL + ' and P.COD_PROD = :mParametro and P.STATUS = ''A'''
          else
            //busca por cód barras
            vTextoSQL:= vTextoSQL + ' and P.COD_BARRA = :mParametro and P.STATUS = ''A''';
        end else begin
          //busca por descrição
          if FEntidadeBase.RegraPesquisa.Equals('Containing') then
            vTextoSQL:= vTextoSQL + ' and upper(P.NOME_PROD) LIKE' + QuotedStr('%') + ' || Upper(:mParametro) || ' + QuotedStr('%') + ' and P.STATUS = ''A'' Order By 2'
          else if FEntidadeBase.RegraPesquisa.Equals('Starting With') then
            vTextoSQL:= vTextoSQL + ' and upper(P.NOME_PROD) LIKE' + ' Upper(:mParametro) || ' + QuotedStr('%') + ' and P.STATUS = ''A'' Order By 2'
        end;
   end;
    //busca por cód barras/descrição
    1: begin
      if CharInSet(FEntidadeBase.TextoPesquisa[1], ['0'..'9']) and (Length(FEntidadeBase.TextoPesquisa) < 14) then
        //busca por cód barras
        vTextoSQL:= vTextoSQL + ' and P.COD_BARRA = :mParametro '
        //Se trabalha com multiplos cod barras
//        If DmFuncoes.MultiplosCodBarras then
//          FEntidadeBase.TextoPesquisa(DmFuncoes.MultBarrasGetCodBarPrincipal(FEntidadeBase.TextoPesquisa));
      else
        //busca por descricao
        vTextoSQL:= vTextoSQL + ' upper(P.NOME_PROD) ' + FEntidadeBase.RegraPesquisa + ' Upper(:mParametro) || ' + QuotedStr('%') + ' and P.STATUS = ''A'' Order By 2';
    end;
    2: begin
      If FEntidadeBase.RegraPesquisa = 'Containing' then
        vTextoSQL:= vTextoSQL + ' Upper(REFERENCIA) containing Upper(:mParametro) and STATUS = ''A'' Order By 2'
      else If FEntidadeBase.RegraPesquisa = 'Starting With' then
        vTextoSQL:= vTextoSQL + ' Upper(REFERENCIA) Like Upper(:mParametro) || ' + QuotedStr('%') + ' and STATUS = ''A'' Order By 2';
    end;
    //procura por Inf. Adicionais
    3: vTextoSQL:= vTextoSQL + ' DETALHE Containing :mParametro and STATUS = ''A'' Order By 2';
    //procura por Marca
    4: vTextoSQL:= vTextoSQL + ' M1.DESCRICAO Containing :mParametro and STATUS = ''A'' Order By 2';
    //procura por Localizacao
    5: vTextoSQL:= vTextoSQL + ' LOCAL Containing :mParametro and STATUS = ''A'' Order By 2';
    //procura por preco
    6: begin
      vTextoSQL:= vTextoSQL + ' PRECOVENDA = :mParametro and STATUS = ''A'' Order By 2';
      FEntidadeBase.TextoPesquisa(StringReplace(FEntidadeBase.TextoPesquisa,',','.',[rfReplaceAll, rfIgnoreCase]));
    end;
  end;
  {$ELSE}
  If ValidaDepto then
    vTextoSQL:= vTextoSQL + ' and M.COD_DEPTO = ' + IntToStr(CodDeptoUsuario);
  if FEntidadeBase.TextoPesquisa <> '' then begin
    //Teclas de atalho
    //Tecla + usada como atalho para busca por código
    If FEntidadeBase.TextoPesquisa.Chars[1] = '+' then begin
      FEntidadeBase.TipoPesquisa(0);
      FEntidadeBase.TextoPesquisa(Copy(FEntidadeBase.TextoPesquisa,2,13));
    end;
    //Tecla * usada como atalho para busca por Cod. Fabricante
    If FEntidadeBase.TextoPesquisa.Chars[1] = '*' then begin
      FEntidadeBase.TipoPesquisa(3);
      FEntidadeBase.RegraPesquisa('Início do texto');
      FEntidadeBase.TextoPesquisa(Copy(FEntidadeBase.TextoPesquisa,2,10));
    end;
    //Tecla $ usada como atalho para busca por Preço
    If FEntidadeBase.TextoPesquisa.Chars[1] = '$' then begin
      FEntidadeBase.TipoPesquisa(7);
      FEntidadeBase.TextoPesquisa(Copy(FEntidadeBase.TextoPesquisa,2,13));
    end;
  end;
  if FEntidadeBase.RegraPesquisa = 'Contendo' then
    FEntidadeBase.RegraPesquisa('Containing')
  else if FEntidadeBase.RegraPesquisa = 'Início do texto' then
    FEntidadeBase.RegraPesquisa('Starting With');
  case FEntidadeBase.TipoPesquisa of
    //busca por código
    0: vTextoSQL:= vTextoSQL + ' and P.COD_PROD = :mParametro ';
    //busca por descrição
    1: begin
      If pos('@', FEntidadeBase.TextoPesquisa) > 0 then begin
        vTextoSQL:= vTextoSQL + ' and upper(P.NOME_PROD) like upper(:mParametro) ';
        FEntidadeBase.TextoPesquisa('%' + StringReplace(FEntidadeBase.TextoPesquisa,'@','%',[rfReplaceAll, rfIgnoreCase]) + '%');
      end else
        vTextoSQL:= vTextoSQL + ' and upper(P.NOME_PROD) ' + FEntidadeBase.RegraPesquisa + ' upper(:mParametro) ';
    end;
    2: begin
      vTextoSQL:= vTextoSQL + ' and P.COD_BARRA = :mParametro ';
      //Se trabalha com multiplos cod barras
      If DmFuncoes.MultiplosCodBarras then
        FEntidadeBase.TextoPesquisa(DmFuncoes.MultBarrasGetCodBarPrincipal(FEntidadeBase.TextoPesquisa));
    end;
    3: begin
      If FEntidadeBase.RegraPesquisa = 'Containing' then
        vTextoSQL:= vTextoSQL + ' and Upper(P.REFERENCIA) containing Upper(:mParametro) '
      else If FEntidadeBase.RegraPesquisa = 'Starting With' then
        vTextoSQL:= vTextoSQL + ' and Upper(P.REFERENCIA) Like Upper(:mParametro) || ' + QuotedStr('%');
    end;
    //procura por Inf. Adicionais
    4: vTextoSQL:= vTextoSQL + ' and P.DETALHE Containing :mParametro ';
    //procura por Marca
    5: vTextoSQL:= vTextoSQL + ' and M1.DESCRICAO Containing :mParametro ';
    //procura por Localizacao
    6: vTextoSQL:= vTextoSQL + ' and P.LOCAL Containing :mParametro ';
    //procura por preco
    7: begin
      vTextoSQL:= vTextoSQL + ' and P.PRECO_VEND = :mParametro ';
      FEntidadeBase.TextoPesquisa(StringReplace(FEntidadeBase.TextoPesquisa,',','.',[rfReplaceAll, rfIgnoreCase]));
    end;
    8: begin
      vTextoSQL:= vTextoSQL + ' and P.COD_BARRA =  :mParametro ';
      FEntidadeBase.TextoPesquisa(FormatFloat('0000000000000', StrToInt(FEntidadeBase.TextoPesquisa)));
    end;
    9:  vTextoSQL:= vTextoSQL + ' and P.COD_FORNEC = :mParametro and P.NOME_PROD Containing :mNome_Prod';
    10: vTextoSQL:= vTextoSQL + ' and P.COD_MARCA = :mParametro and P.NOME_PROD Containing :mNome_Prod';
    11: vTextoSQL:= vTextoSQL + ' and P.COD_MARCA1 = :mParametro and P.NOME_PROD Containing :mNome_Prod';
    12: vTextoSQL:= vTextoSQL + ' and P.COD_SUBGRUPO = :mParametro and P.NOME_PROD Containing :mNome_Prod';
  end;
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and P.STATUS = ' + QuotedStr('A');
  {$ENDIF}
  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NOME_PROD');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  if FEntidadeBase.TipoPesquisa <> -1 then
    ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TProduto.InicializaDataSource(Value: TDataSource): iEntidadeProduto;
var
  vTextoSQL: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  vTextoSQL:= FEntidadeBase.TextoSQL + ' and P.COD_PROD = :mParametro and STATUS = ''A'' Order By 2';
  FEntidadeBase.AddParametro('mCodFilial', 1, ftInteger);
  FEntidadeBase.AddParametro('mParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(vTextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TProduto.ModificaDisplayCampos;
begin
  {$IFDEF APP}
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_VEND')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_PRAZ')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.00';
  {$ELSE}
  case AnsiIndexStr(TipoConsulta, ['Consulta', 'Filtra', 'Cadastro']) of
  0:
    begin
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO')).currency:= True;
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRAZO')).currency:= True;
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.00';
    end;
  1:
    begin
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO')).currency:= True;
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRAZO')).currency:= True;
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.00';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_CUST')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('C_MEDIO')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('MARGEM')).DisplayFormat:= '#,0.00';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANT_MIN')).DisplayFormat:= '#,0.00';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PESO')).DisplayFormat:= '#,0.000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('REDBASECALC')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('ISS')).DisplayFormat:= '#,0.00';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECOCOMPRA')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('IPI')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('FRETE')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('FINANCEIRO')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('SUBSTITUICAO')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('IVAST')).DisplayFormat:= '#,0.00';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('REDBCICMSST')).DisplayFormat:= '#,0.00';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('IPI_SAIDA')).DisplayFormat:= '#,0.00';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PIS_ALIQ')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('COFINS_ALIQ')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PIS_ENTRADA_ALIQ')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('COFINS_ENTRADA_ALIQ')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QTD_EMBALAGEM_COMPRA')).DisplayFormat:= '#,0.000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('FPOP_UN_PRECO')).DisplayFormat:= '#,0.000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('FPOP_PRECO')).currency:= True;
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('FPOP_PRECO_BOLSAFAMILIA')).currency:= True;
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VOLUME')).DisplayFormat:= '#,0.000000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('COMPRIMENTO')).DisplayFormat:= '#,0.000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('LARGURA')).DisplayFormat:= '#,0.000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('ALTURA')).DisplayFormat:= '#,0.000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('ICMS_DIFERENCA')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('MARGEM_LUCRO')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('DECOMPOSICAO_PORC_PERDA')).DisplayFormat:= '#,0.00';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_ECOMMERCE')).currency:= True;
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_VEND')).currency:= True;
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_PRAZ')).currency:= True;
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.00';
    end;
  2:
    begin
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_CUST')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('C_MEDIO')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('MARGEM')).DisplayFormat:= '#,0.00';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANT_MIN')).DisplayFormat:= '#,0.00';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PESO')).DisplayFormat:= '#,0.000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('REDBASECALC')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('ISS')).DisplayFormat:= '#,0.00';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECOCOMPRA')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('IPI')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('FRETE')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('FINANCEIRO')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('SUBSTITUICAO')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('IVAST')).DisplayFormat:= '#,0.00';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('REDBCICMSST')).DisplayFormat:= '#,0.00';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('IPI_SAIDA')).DisplayFormat:= '#,0.00';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PIS_ALIQ')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('COFINS_ALIQ')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PIS_ENTRADA_ALIQ')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('COFINS_ENTRADA_ALIQ')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QTD_EMBALAGEM_COMPRA')).DisplayFormat:= '#,0.000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('FPOP_UN_PRECO')).DisplayFormat:= '#,0.000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('FPOP_PRECO')).currency:= True;
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('FPOP_PRECO_BOLSAFAMILIA')).currency:= True;
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VOLUME')).DisplayFormat:= '#,0.000000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('COMPRIMENTO')).DisplayFormat:= '#,0.000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('LARGURA')).DisplayFormat:= '#,0.000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('ALTURA')).DisplayFormat:= '#,0.000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('ICMS_DIFERENCA')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('MARGEM_LUCRO')).DisplayFormat:= '#,0.0000';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('DECOMPOSICAO_PORC_PERDA')).DisplayFormat:= '#,0.00';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_ECOMMERCE')).currency:= True;
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_VEND')).currency:= True;
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PRECO_PRAZ')).currency:= True;
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('QUANTIDADE')).DisplayFormat:= '#,0.00';
      TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('DESCONTO')).DisplayFormat:= '#,0.00';
      TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('DTCADASTRO')).EditMask:= '!99/99/00;1;_';
    end;
  end;
  {$ENDIF}
end;
function TProduto.ValidaDepto: boolean;
begin
  Result:= FValidaDepto;
end;
function TProduto.ValidaDepto(pValue: boolean): iEntidadeProduto;
begin
  Result:= Self;
  FValidaDepto:= pValue;
end;
function TProduto.CodDeptoUsuario: Integer;
begin
  Result:= FCodDeptoUsuario;
end;
function TProduto.CodDeptoUsuario(pValue: Integer): iEntidadeProduto;
begin
  Result:= Self;
  FCodDeptoUsuario:= pValue;
end;
function TProduto.TipoConsulta(pValue: String): iEntidadeProduto;
begin
  Result:= Self;
  FTipoConsulta:= pValue;
end;
function TProduto.TipoConsulta: String;
begin
  Result:= FTipoConsulta;
end;
function TProduto.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
end.
