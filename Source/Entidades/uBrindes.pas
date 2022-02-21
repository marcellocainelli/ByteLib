unit uBrindes;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TBrindes = class(TInterfacedObject, iEntidade)
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

{ TBrindes }

constructor TBrindes.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * from BRINDES ');
end;

destructor TBrindes.Destroy;
begin
  inherited;
end;

class function TBrindes.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TBrindes.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TBrindes.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where ID = :mParametro';
    1: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where DESCRICAO Containing :mParametro';
  End;
  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TBrindes.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TBrindes.ModificaDisplayCampos;
begin

end;

end.
