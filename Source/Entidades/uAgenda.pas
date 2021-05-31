unit uAgenda;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TAgenda = class(TInterfacedObject, iEntidade)
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

{ TGrupo }

constructor TAgenda.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from AGENDA where ATIVO_INATIVO = ''A'' and COD_FUNCI = :pCod_Funci');
end;

destructor TAgenda.Destroy;
begin
  inherited;
end;

class function TAgenda.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TAgenda.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TAgenda.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  vTextoSql:= FEntidadeBase.TextoSQL;

  case FEntidadeBase.TipoPesquisa of
    0: vTextoSql:= vTextoSql + ' and STATUS = ''A''';
    1: vTextoSql:= vTextoSql + ' and STATUS = ''R''';
    2: vTextoSql:= vTextoSql + ' and STATUS = ''C''';
  end;

  FEntidadeBase.AddParametro('pCod_Funci', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('TITULO');
  FEntidadeBase.Iquery.SQL(vTextoSql);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TAgenda.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('TITULO');
  FEntidadeBase.AddParametro('pCod_Funci', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TAgenda.ModificaDisplayCampos;
begin

end;

end.
