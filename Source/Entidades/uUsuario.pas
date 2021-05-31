unit uUsuario;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TUsuario = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource): iEntidade;
      function InicializaDataSource(Value: TDataSource): iEntidade;

      procedure ModificaDisplayCampos;
  end;

implementation

uses
  uEntidadeBase;

{ TUsuario }

constructor TUsuario.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select U.COD_CAIXA,U.COD_CAIXA as CODIGO,U.NOME,U.SENHA,U.PRIORIDADE,U.PATHBYTESUPER,U.DTSINC,U.DESCONTOMAXIMO,U.DESCMAXRECTO,U.LIBERABLOQUEIO,U.LEMBRETES,U.DTLEMBRETE, '+
                         'U.STATUS,U.COD_FUNCI,U.COD_FILIAL,U.TROCAFILIAL,U.LANCAOUTRASSAIDAS,U.COD_DEPTO,U.CAIXA_RECEBIMENTO,U.CAIXA_MOVIMENTO,U.CAIXA_DESPESAS,U.CAIXA_ORCAMENTO, '+
                         'U.CAIXA_DEVOLUCAO,U.CANCELA_CUPOMFISCAL, 0 as INDICE '+
                         'from USUARIO U '+
                         'Where STATUS = ''A''');
end;

destructor TUsuario.Destroy;
begin
  inherited;
end;

class function TUsuario.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TUsuario.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TUsuario.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TUsuario.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('NOME');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TUsuario.ModificaDisplayCampos;
begin

end;

end.
