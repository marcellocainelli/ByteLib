unit uCliente;
interface
uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, Byte.Lib;
Type
  TCliente = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
      procedure OnNewRecord(DataSet: TDataSet);
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
  end;
implementation
uses
  uEntidadeBase;
{ TCliente }
constructor TCliente.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * From CADCLI Where (1=1) and ');
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;
destructor TCliente.Destroy;
begin
  inherited;
end;
class function TCliente.New: iEntidade;
begin
  Result:= Self.Create;
end;
function TCliente.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;
function TCliente.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
  vNumeroAux: integer;
  vDataAux: TDateTime;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSql;
  {$IFDEF APP}
  FEntidadeBase.TextoSQL(
    'Select CODIGO, NOME, ENDERECO, END_COMPLEMENTO, NUMERO, BAIRRO, CEP, CIDADE, UF, TIPO, CGC, IE, DDD, FONE, FONE1, OBS, DETALHE, EMAIL, LIMITE, ' +
    'COD_CONV, DT_SINCRONISMO, DTATUALIZACAO, COD_MUNICIPIO, COD_PAIS From CADCLI Where (1=1) and '
  );
  vTextoSQL:= FEntidadeBase.TextoSql;
  if FEntidadeBase.RegraPesquisa = 'Contendo' then
    FEntidadeBase.RegraPesquisa('Containing')
  else if FEntidadeBase.RegraPesquisa = 'Início do texto' then
    FEntidadeBase.RegraPesquisa('Starting With');
  case FEntidadeBase.TipoPesquisa of
    0: begin
        if (not FEntidadeBase.TextoPesquisa.Equals(EmptyStr)) and (TryStrToInt(FEntidadeBase.TextoPesquisa, vNumeroAux)) then
          //busca por código
          vTextoSQL:= vTextoSQL + ' CODIGO = :Parametro'
        else begin
          if FEntidadeBase.RegraPesquisa.Equals('Containing') then
            vTextoSQL:= vTextoSQL + ' Upper(NOME) LIKE' + QuotedStr('%') + ' || Upper(:Parametro) || ' + QuotedStr('%') + ' Order By 2'
          else if FEntidadeBase.RegraPesquisa.Equals('Starting With') then
            vTextoSQL:= vTextoSQL + ' Upper(NOME) LIKE' + ' Upper(:Parametro) || ' + QuotedStr('%') + ' Order By 2';
        end;
       end;
    1: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(ENDERECO) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    2: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(BAIRRO) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    3: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(CIDADE) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    4: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(FONE) Containing Upper(:Parametro)';
    5: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(RAZAOSOCIAL) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    6: begin
        vTextoSQL:= FEntidadeBase.TextoSql + '(SELECT Retorno FROM spApenasNumeros(CGC) as so_numero) = :Parametro';
        FEntidadeBase.TextoPesquisa(TLib.SomenteNumero(FEntidadeBase.TextoPesquisa));
    end;
    7: vTextoSQL:='Select c.* From CADCLI c Where c.codigo in (SELECT v.cod_cli FROM CARRO v where v.placa Containing :Parametro)';
  end;
  {$ELSE}
  if FEntidadeBase.RegraPesquisa = 'Contendo' then
      FEntidadeBase.RegraPesquisa('Containing')
  else If FEntidadeBase.RegraPesquisa = 'Início do texto' then
    FEntidadeBase.RegraPesquisa('Starting With');
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSql + 'CODIGO = :Parametro';
    1: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(NOME) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    2: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(ENDERECO) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    3: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(END_COMPLEMENTO) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    4: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(BAIRRO) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    5: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(CIDADE) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    6: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(FONE) Containing Upper(:Parametro)';
    7: vTextoSQL:= FEntidadeBase.TextoSql + 'Upper(RAZAOSOCIAL) ' + FEntidadeBase.RegraPesquisa + ' Upper(:Parametro)';
    8:
    begin
      vTextoSQL:= FEntidadeBase.TextoSql + '(SELECT Retorno FROM spApenasNumeros(CGC) as so_numero) Containing :Parametro';
      FEntidadeBase.TextoPesquisa(TLib.SomenteNumero(FEntidadeBase.TextoPesquisa));
    end;
    9: vTextoSQL:= FEntidadeBase.TextoSql + 'DETALHE containing :Parametro';
    10:
    begin
      if TryStrToDate(FEntidadeBase.TextoPesquisa, vDataAux) then begin
        FEntidadeBase.TextoPesquisa(FormatDateTime('mm/dd/yyyy', vDataAux));
        vTextoSQL:= FEntidadeBase.TextoSql + 'NASC = :Parametro';
      end else
        vTextoSQL:='Select c.* From CADCLI c Where c.codigo in (SELECT v.cod_cli FROM CARRO v where v.placa Containing :Parametro)';
    end;
    11: vTextoSQL:='Select c.* From CADCLI c Where c.codigo in (' + FEntidadeBase.TextoPesquisa + ')';
  end;
  {$ENDIF}
  if FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and OBS <> ' + QuotedStr('INT') + ' Order By 2';
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  {$IFNDEF APP}
  ModificaDisplayCampos;
  {$ENDIF}
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
function TCliente.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.AddParametro('Parametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' CODIGO = :Parametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
procedure TCliente.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('nasc')).EditMask:= '!99/99/00;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('nas_co')).EditMask:= '!99/99/00;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('emp_admissao')).EditMask:= '!99/99/00;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('cep')).EditMask:= '00000\-999;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('cob_cep')).EditMask:= '00000\-999;1;_';
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('emp_cep')).EditMask:= '00000\-999;1;_';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('limite')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('honorario')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('emp_renda')).currency:= True;
  TStringField(FEntidadeBase.Iquery.Dataset.FieldByName('cpf_co')).EditMask:= '###.###.###-##;1;_';
end;
function TCliente.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;
procedure TCliente.OnNewRecord(DataSet: TDataSet);
begin
{$IFNDEF APP}
  FEntidadeBase.Iquery.DataSet.FieldByName('COD_PAIS').AsInteger:= 1058;
  FEntidadeBase.Iquery.DataSet.FieldByName('COD_CONV').AsInteger:= 1;
  FEntidadeBase.Iquery.DataSet.FieldByName('FLAG_IMPR_REL_GERENCIAL').AsString:= 'S';
  FEntidadeBase.Iquery.DataSet.FieldByName('FLAG_BLOQUEIO').AsString:= 'S';
  FEntidadeBase.Iquery.DataSet.FieldByName('FLAG_EMITIR_NFSE').AsString:= 'N';
  FEntidadeBase.Iquery.DataSet.FieldByName('FLAG_PEDE_KM').AsString:= 'N';
  FEntidadeBase.Iquery.DataSet.FieldByName('FLAG_ENVIAR_SAT_EMAIL').AsString:= 'N';
  FEntidadeBase.Iquery.DataSet.FieldByName('TIPO').AsString:= 'F';
  FEntidadeBase.Iquery.DataSet.FieldByName('FLAG_ENVIAR_SATNFE_ZAP').AsString:= 'N';
  FEntidadeBase.Iquery.DataSet.FieldByName('FLAG_PRECOCUSTO').AsString:= 'N';
  FEntidadeBase.Iquery.DataSet.FieldByName('OBS').AsString:= 'ATV';
{$ENDIF}
end;
end.
