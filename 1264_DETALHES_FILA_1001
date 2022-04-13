declare
  v_empresa   number(3) := :p_1;
  v_op        number(8) := :p_2;
  v_etapa     number(3) := :p_3;
  v_recurso   number(4) := :p_4;
  v_atributo  varchar2(50);
  v_prompt    varchar2(50);
  v_atributo2 varchar2(50);
  v_prompt2   varchar2(50);
  v_atributo3 varchar2(50);
  v_prompt3   varchar2(50);
  v_atributo4 varchar2(500);
  v_prompt4   varchar2(50);  
  v_previsao varchar2(20);
  v_prompt5   varchar2(50);
  v_prompt6   varchar2(50);
  v_prompt7  varchar2(100);
  v_prompt8  varchar2(100);
  v_atributo10 varchar2(500);
  v_pig       varchar2(50);
  v_aditivo       varchar2(500);
  v_qtde_comp number := 0;
  v_qtde_aditivo number := 0;
  v_qtde_comp_ext number := 0;
  v_qtde_item number := 0;
  v_bobinas number:=0;
  v_evoh    number:=0;
  v_acerto_anterior number:=0;
  v_op_principal number(8);
  v_desc_comp    varchar2(200);
  v_desc_aditivo    varchar2(200);
  v_desc_comp_ext    varchar2(200);  
  v_observacao   varchar2(100);
  v_composicao   varchar2(100);
  v_retorno varchar2(1000);
  v_produto   varchar2(20);
  v_versao    varchar2(10);
  v_produto_filho varchar2(30);
  v_versao_filho  varchar2(10);

  v_tipo_solda varchar2(1000);

BEGIN

  select max(op_principal), max(produto), max(versao), max(composicao) 
    into v_op_principal, v_produto, v_versao, v_composicao
    from pcpop
   where empresa = v_empresa
     and op = v_op;

   v_produto_filho:=v_produto;
   v_versao_filho:=v_versao;

  if v_op_principal is not null then
    select max(produto), max(versao)
      into v_produto, v_versao
      from pcpop
     where empresa = v_empresa
       and op = v_op_principal;
  end if;

    select max(localizacao||' '||area||' '||secao) into v_prompt8
      from pcpacessorio
     where empresa = v_empresa
       and codigo = (select max(acessorio)
                       from pcpitemace
                      where empresa = v_empresa
                        and ((produto,versao) = (select produto, versao
                                                   from pcpop
                                                  where empresa = v_empresa
                                                    and op = v_op) 
                                                     or
                                                        (produto,versao) = (select produto, versao
                                                                              from pcpop
                                                                             where empresa = v_empresa
                                                                               and op = v_op_principal)));


  if v_etapa in (10,11,12) then

    v_qtde_comp_ext := 0;
    for r_pig in (select pcpopcomponente.seq_aplicacao||'/'||estitem.referencia componente
                     from pcpopcomponente, estitem
                    where pcpopcomponente.empresa = v_empresa
                      and pcpopcomponente.op = v_op
                      and nvl(pcpopcomponente.etapa_aplicacao, v_etapa) = v_etapa
                      and pcpopcomponente.empresa = estitem.empresa
                      and pcpopcomponente.componente = estitem.codigo
                      and estitem.tipo_item = 21
                      and estitem.grupo = 100
                      and estitem.subgrupo = 2
                    order by pcpopcomponente.seq_aplicacao) loop
       v_desc_comp_ext := v_desc_comp_ext||' '||r_pig.componente; 
       v_qtde_comp_ext := v_qtde_comp_ext + 1;
    end loop;

    for r_aditivo in (select pcpopcomponente.seq_aplicacao||'/'||estitem.descricao componente
                     from pcpopcomponente, estitem
                    where pcpopcomponente.empresa = v_empresa
                      and pcpopcomponente.op = v_op
                      and nvl(pcpopcomponente.etapa_aplicacao, v_etapa) = v_etapa
                      and pcpopcomponente.empresa = estitem.empresa
                      and pcpopcomponente.componente = estitem.codigo
                      and estitem.tipo_item = 21
                      and estitem.grupo = 100
                      and estitem.subgrupo IN (5,43)
                      and (estitem.descricao like '%OPEN%'
                        or estitem.descricao like '%SURLYN%')
                    order by pcpopcomponente.seq_aplicacao) loop
       v_desc_aditivo := v_desc_aditivo||' '||r_aditivo.componente; 
       v_qtde_aditivo := v_qtde_aditivo + 1;
    end loop;
    
    if v_qtde_comp_ext > 0 then
      v_pig := rtrim(v_pig) ||' /// Pig: '||v_desc_comp_ext;
    end if;     

    if v_qtde_aditivo > 0 then
      v_aditivo := rtrim(v_aditivo) ||' /// ADITIVO: '||v_desc_aditivo;
    end if;     

    
    v_prompt := 'Larg.Ext:';
    select max(valor_padrao) into v_atributo
      from pcpficcargarec
     where empresa = v_empresa
       and class_carga_recurso = v_produto
       and etapa = v_etapa
       and recurso = v_recurso
       and atributo = 5078;
    
    select count(*) into v_evoh
      from pcpopcomponente, estitem
     where pcpopcomponente.empresa = 1
       and pcpopcomponente.empresa = estitem.empresa
       and pcpopcomponente.componente = estitem.codigo
       and estitem.tipo_item = 21
       and (estitem.descricao like '%EVAL%' or
            estitem.descricao like '%EVOH%')
       and pcpopcomponente.empresa = v_empresa
       and pcpopcomponente.op = v_op;
     if v_evoh > 0 then
       v_prompt6:=' EVOH ';
     end if;
    
    if v_atributo is null then 
      v_atributo := f_busca_valor_ficha(v_empresa,v_produto,v_versao,v_op,123);
    end if;
    
    v_prompt2 := 'Pigmentado:';  
    select max(valor_padrao) into v_atributo2
      from pcpficcargarec
     where empresa = v_empresa
       and class_carga_recurso = v_produto
       and etapa = v_etapa
       and recurso = v_recurso
       and atributo = 5079;
       
    if v_atributo2 is null then 
       v_atributo2 := f_busca_valor_ficha(v_empresa,v_produto,v_versao,null,63);
    end if;
     
     if v_atributo2='SIM' then
       select max(valor_padrao) into v_atributo2
         from pcpficcargarec
        where empresa = v_empresa
          and class_carga_recurso = v_produto
          and etapa = v_etapa
          and recurso = v_recurso
          and atributo = 5080;
          
       if v_atributo3 is null then
         v_atributo3 := f_busca_valor_ficha(v_empresa,v_produto,v_versao,null,65);
      end if;
    end if;  	    	
    
  elsif v_etapa = 20 then

    v_qtde_comp := 0;
    for r_comp in (select pcpopcomponente.seq_aplicacao||'/'||estitem.referencia componente
                     from pcpopcomponente, estitem
                    where pcpopcomponente.empresa = v_empresa
                      and pcpopcomponente.op = nvl(v_op_principal, v_op)
                      and nvl(pcpopcomponente.etapa_aplicacao, v_etapa) = v_etapa
                      and pcpopcomponente.empresa = estitem.empresa
                      and pcpopcomponente.componente = estitem.codigo
                      and estitem.tipo_item = 11
                    order by pcpopcomponente.seq_aplicacao) loop
       v_desc_comp := v_desc_comp||' '||r_comp.componente; 
       v_qtde_comp := v_qtde_comp + 1;
    end loop;   
    
    v_prompt := 'C:';
    select max(valor_padrao) into v_atributo
      from pcpficcargarec
     where empresa = v_empresa
       and class_carga_recurso = v_produto
       and etapa = v_etapa
       and recurso = v_recurso
       and atributo = 5081;
    
    if v_atributo is null then 
      v_atributo := f_busca_valor_ficha(v_empresa,v_produto,v_versao,null,24);
    end if;
    
    v_prompt2 := 'G:';
    select max(valor_padrao) into v_atributo2
      from pcpficcargarec
     where empresa = v_empresa
       and class_carga_recurso = v_produto
       and etapa = v_etapa
       and recurso = v_recurso
       and atributo = 5082; 
    if v_atributo2 is null then 
      v_atributo2 := f_busca_valor_ficha(v_empresa,v_produto,v_versao,null,950);
    end if;
    
    v_prompt4 := 'Obs:';
    select max(valor_padrao) into v_atributo4
      from pcpficcargarec
     where empresa = v_empresa
       and class_carga_recurso = v_produto
       and etapa = v_etapa
       and recurso = v_recurso
       and atributo = 5083; 
     if v_atributo4 is null then 
       v_atributo4 := f_busca_valor_ficha(v_empresa,v_produto,v_versao,null,68);
     end if;

  elsif v_etapa = 70 then
   v_prompt5:=' PREVISÃO ENTREGA:';
    select max(COMPEDIT.PREVISAO_ENT)
      into v_previsao
      from compedit, COMPED
     where compedit.empresa = v_empresa
       and compedit.empresa = comped.empresa
       and compedit.pedido = comped.pedido
       and comped.data_faturamento is not null
       and compedit.op = v_op;

    select nvl(max(observacao),'+AA+') 
      into v_observacao
      from pcpoprecurso
     where empresa = v_empresa
       and op = v_op
       and etapa = v_etapa
       and recurso = v_recurso;

    select nvl(sum(qtd_entrada),0) 
      into v_qtde_item
      from compedit
     where empresa = v_empresa
       and op = v_op;
  
  else
     v_atributo := null;
     v_prompt := '';
     v_atributo2 := null;
     v_prompt2 := '';
     v_atributo4 := null;
     v_prompt4 := '';    
     v_previsao := null;
     v_prompt5 := '';   
     v_prompt6 := '';
     
  end if;

  if v_etapa = 20 then
    --Buscar bobinas filhas
    select count(1) into v_bobinas
      from pcpapproducao
     where empresa = v_empresa
       and etapa in (10,11,70)
       and op = v_op;
 
    select max(decode(pcpetapa.tempo_recursos, 'H', 
                     pcpcaprecurso.tempo_acerto/60,
                     pcpcaprecurso.tempo_acerto)) 
     into v_acerto_anterior
     from pcpcaprecurso, pcpetapa
    where pcpetapa.empresa = pcpcaprecurso.empresa
      and pcpetapa.codigo = pcpcaprecurso.etapa
      and pcpcaprecurso.empresa = v_empresa
      and pcpcaprecurso.etapa = v_etapa
      and pcpcaprecurso.recurso = v_recurso
      and pcpcaprecurso.class_carga_recurso = v_produto;
      
  end if;

  if v_etapa in (10,11) then
    v_tipo_solda :=f_busca_valor_ficha(v_empresa,v_produto,v_versao,null,6);
  end if;

  if v_qtde_comp > 0 then
    v_retorno := rtrim(v_retorno) || 'Cs:' || v_qtde_comp||' '||v_desc_comp;
  end if;
  if v_atributo is not null then
    v_retorno := v_retorno||' /  '|| rtrim(v_prompt) || ' ' || rtrim(v_atributo);
  end if;
  if v_atributo2 is not null then
    v_retorno := rtrim(v_retorno) || ' /  ' || rtrim(v_prompt2) || ' ' || rtrim(v_atributo2);
  end if;
   if v_tipo_solda is not null then
    v_retorno :=rtrim(v_tipo_solda);
  end if;
  if v_atributo3 is not null then
    v_retorno := rtrim(v_retorno) || ' / ' ||  rtrim(v_atributo3);
  end if;
  if v_atributo4 is not null and v_etapa=20 then
    v_retorno := rtrim(v_retorno) || ' / ' ||  rtrim(v_atributo4);
  end if;
    if v_bobinas > 0 then                 
      v_retorno := v_retorno ||' / Bobinas: '||v_bobinas;
    end if;
    
    if v_acerto_anterior > 0 then                 
      v_retorno := v_retorno ||' / Acto Ant(min): '||v_acerto_anterior;
    end if;    

  if v_previsao is not null and v_etapa=70 then
    v_retorno := rtrim(v_prompt5)||' '|| rtrim(v_previsao)||' - Qtde Entregue: '||v_qtde_item;
  end if;

    if v_observacao not in ('+AA+') and v_etapa = 70 then
      update pcpoprecurso 
         set observacao = v_observacao 
       where empresa = v_empresa 
         and op = v_op 
         and etapa = v_etapa 
         and recurso = v_recurso;
    end if;

  if v_evoh >0 and v_etapa in (10,11,12) then
    v_retorno := rtrim(v_retorno) || ' / ' ||  rtrim(v_prompt6);
  end if;

  if v_prompt8 is not null and v_recurso between 210 and 298 then
    v_retorno := rtrim(v_retorno) || ' / Loc. Acessorio: ' ||v_prompt8;  
  end if;

  if v_etapa in (30,31,32, 33,34,35) then
    
    select max(valor_padrao)
      into v_atributo10
      from pcpficha
     where empresa = v_empresa
       and produto = v_produto_filho
       and versao = v_versao_filho
       and atributo = 123;
    
  end if;

  if v_etapa < 20 then 
    :p_5 := v_retorno||v_pig||' COMPOSICAO: '||v_composicao;
    else
      :p_5 := v_retorno||v_pig||' COMPOSICAO: '||v_composicao||' LARG. EMB: '||v_atributo10;
  end if;
  
  if v_qtde_aditivo > 0 then
    :p_5 := v_retorno||' '||v_desc_aditivo;
  end if;
  
exception
when others then
:p_5 := sqlerrm;
END;
