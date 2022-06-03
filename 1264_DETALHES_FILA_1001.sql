 /*
Comando 1264
*/
DECLARE
    v_empresa   number(3) := :p_1;
    v_op        number(8) := :p_2;
    v_etapa     number(3) := :p_3;
    v_recurso   number(4) := :p_4;
    v_atributo        VARCHAR2(50);
    v_prompt          VARCHAR2(50);
    v_atributo2       VARCHAR2(50);
    v_prompt2         VARCHAR2(50);
    v_descPigmento    VARCHAR2(50);
    v_prompt3         VARCHAR2(50);
    v_atributo4       VARCHAR2(500);
    v_prompt4         VARCHAR2(50);
    v_previsao        VARCHAR2(20);
    v_prompt5         VARCHAR2(50);
    v_prompt6         VARCHAR2(50);
    v_prompt7         VARCHAR2(100);
    v_prompt8         VARCHAR2(100);
    v_atributo10      VARCHAR2(500);
    v_pig             VARCHAR2(50);
    v_aditivo         VARCHAR2(500);
    v_qtde_comp       NUMBER := 0;
    v_qtde_aditivo    NUMBER := 0;
    v_qtde_comp_ext   NUMBER := 0;
    v_qtde_item       NUMBER := 0;
    v_bobinas         NUMBER := 0;
    v_evoh            NUMBER := 0;
    v_acerto_anterior NUMBER := 0;
    v_op_principal    NUMBER(8);
    v_desc_comp       VARCHAR2(200);
    v_desc_aditivo    VARCHAR2(200);
    v_desc_comp_ext   VARCHAR2(200);
    v_observacao      VARCHAR2(100);
    v_composicao      VARCHAR2(100);
    v_retorno         VARCHAR2(1000);
    v_produto         VARCHAR2(20);
    v_versao          VARCHAR2(10);
    v_produto_filho   VARCHAR2(30);
    v_versao_filho    VARCHAR2(10);
    v_tipo_solda      VARCHAR2(1000);
    v_comp_affinity        NUMBER := 0;
    
BEGIN
    
    SELECT Max(op_principal),
           Max(produto),
           Max(versao),
           Max(composicao)
    INTO   v_op_principal, v_produto, v_versao, v_composicao
    FROM   pcpop
    WHERE  empresa = v_empresa
           AND op = v_op;

    v_produto_filho := v_produto;
    v_versao_filho := v_versao;

    IF v_op_principal IS NOT NULL THEN
      SELECT Max(produto),
             Max(versao)
      INTO   v_produto, v_versao
      FROM   pcpop
      WHERE  empresa = v_empresa
             AND op = v_op_principal;
    END IF;

    SELECT Max(localizacao
               ||' '
               ||area
               ||' '
               ||secao)
    INTO   v_prompt8
    FROM   pcpacessorio
    WHERE  empresa = v_empresa
           AND codigo = (SELECT Max(acessorio)
                         FROM   pcpitemace
                         WHERE  empresa = v_empresa
                                AND ( ( produto, versao ) = (SELECT produto,
                                                                    versao
                                                             FROM   pcpop
                                                             WHERE
                                      empresa = v_empresa
                                      AND op = v_op)
                                       OR ( produto, versao ) =
                                          (SELECT produto,
                                                  versao
                                           FROM   pcpop
                                           WHERE  empresa = v_empresa
                                                  AND op = v_op_principal
                                          ) ));

    IF v_etapa IN ( 10, 11, 12 ) THEN
      v_qtde_comp_ext := 0;

      FOR r_pig IN (SELECT pcpopcomponente.seq_aplicacao
                           ||'/'
                           ||estitem.referencia componente
                    FROM   pcpopcomponente,
                           estitem
                    WHERE  pcpopcomponente.empresa = v_empresa
                           AND pcpopcomponente.op = v_op
                           AND Nvl(pcpopcomponente.etapa_aplicacao, v_etapa) =
                               v_etapa
                           AND pcpopcomponente.empresa = estitem.empresa
                           AND pcpopcomponente.componente = estitem.codigo
                           AND estitem.tipo_item = 21
                           AND estitem.grupo = 100
                           AND estitem.subgrupo = 2
                    ORDER  BY pcpopcomponente.seq_aplicacao) LOOP
                    
          v_desc_comp_ext := v_desc_comp_ext
                             ||' '
                             ||r_pig.componente;

          v_qtde_comp_ext := v_qtde_comp_ext + 1;
          
      END LOOP;

      FOR r_aditivo IN (SELECT pcpopcomponente.seq_aplicacao
                               ||'/'
                               ||estitem.descricao componente
                        FROM   pcpopcomponente,
                               estitem
                        WHERE  pcpopcomponente.empresa = v_empresa
                               AND pcpopcomponente.op = v_op
                               AND Nvl(pcpopcomponente.etapa_aplicacao, v_etapa)
                                   =
                                   v_etapa
                               AND pcpopcomponente.empresa = estitem.empresa
                               AND pcpopcomponente.componente = estitem.codigo
                               AND estitem.tipo_item = 21
                               AND estitem.grupo = 100
                               AND estitem.subgrupo IN ( 5, 43 )
                               AND ( estitem.descricao LIKE '%OPEN%'
                                      OR estitem.descricao LIKE '%SURLYN%' )
                        ORDER  BY pcpopcomponente.seq_aplicacao)
          
          LOOP
          v_desc_aditivo := v_desc_aditivo
                            ||' '
                            ||r_aditivo.componente;

          v_qtde_aditivo := v_qtde_aditivo + 1;
          
      END LOOP;

      IF v_qtde_comp_ext > 0 THEN
        -- Pigmento que aparece na extrusão
        v_pig := Rtrim(v_pig) ||' /// Pig: '||v_desc_comp_ext;
      END IF;

      IF v_qtde_aditivo > 0 THEN
        v_aditivo := Rtrim(v_aditivo)||' /// ADITIVO: '||v_desc_aditivo;
      END IF;

      v_prompt := 'Larg.Ext:';

      SELECT Max(valor_padrao)
      INTO   v_atributo
      FROM   pcpficcargarec
      WHERE  empresa = v_empresa
             AND class_carga_recurso = v_produto
             AND etapa = v_etapa
             AND recurso = v_recurso
             AND atributo = 5078;

      -- Se possui EVOH na descricao do componente
      SELECT Count(*)
      INTO   v_evoh
      FROM   pcpopcomponente,
             estitem
      WHERE  pcpopcomponente.empresa = 1
             AND pcpopcomponente.empresa = estitem.empresa
             AND pcpopcomponente.componente = estitem.codigo
             AND estitem.tipo_item = 21
             AND ( estitem.descricao LIKE '%EVAL%'
                    OR estitem.descricao LIKE '%EVOH%' )
             AND pcpopcomponente.empresa = v_empresa
             AND pcpopcomponente.op = v_op;
               
       -- Se possui AFFINITY na descricao do componente
      SELECT Count(*)
      INTO   v_comp_affinity
      FROM   pcpopcomponente,
             estitem
      WHERE  pcpopcomponente.empresa = 1
             AND pcpopcomponente.empresa = estitem.empresa
             AND pcpopcomponente.componente = estitem.codigo
             --AND estitem.tipo_item = 2
             AND ( estitem.descricao LIKE '%AFF%'
                    OR estitem.descricao LIKE '%NITY%' )
             AND pcpopcomponente.empresa = v_empresa
             AND pcpopcomponente.op = v_op;
             

      IF v_evoh > 0 AND v_comp_affinity = 0 THEN
        v_prompt6 := 'EVOH';
        
      ELSIF v_evoh = 0 AND v_comp_affinity > 0 THEN
        v_prompt6 := 'AFFINITY';
        
      ELSIF v_evoh > 0 AND v_comp_affinity > 0 THEN
        v_prompt6 := 'EVOH / AFFINITY';
        
      END IF;

      IF v_atributo IS NULL THEN
        -- Largura de embobinamento
        v_atributo := F_busca_valor_ficha(v_empresa, v_produto, v_versao, v_op, 123);
      END IF;

      v_prompt2 := 'Pigmentado:';

      SELECT Max(valor_padrao)
      INTO   v_atributo2
      FROM   pcpficcargarec
      WHERE  empresa = v_empresa
             AND class_carga_recurso = v_produto
             AND etapa = v_etapa
             AND recurso = v_recurso
             AND atributo = 5079;

      IF v_atributo2 IS NULL THEN
        v_atributo2:= F_busca_valor_ficha(v_empresa, v_produto, v_versao, NULL,63);
        
      END IF;

      IF v_atributo2 = 'SIM' THEN
        SELECT Max(valor_padrao)
        INTO   v_atributo2
        FROM   pcpficcargarec
        WHERE  empresa = v_empresa
               AND class_carga_recurso = v_produto
               AND etapa = v_etapa
               AND recurso = v_recurso
               AND atributo = 5080;
               
        -- Atributo 65: DESCRICAO_PIGMENTO
        IF v_descPigmento IS NULL THEN
          v_descPigmento := F_busca_valor_ficha(v_empresa, v_produto, v_versao,NULL,65);
        END IF;
        
      END IF;
      
    ELSIF v_etapa = 20 THEN
      v_qtde_comp := 0;

      FOR r_comp IN (SELECT pcpopcomponente.seq_aplicacao || '/' || estitem.referencia componente
                     FROM   pcpopcomponente,
                            estitem
                     WHERE  pcpopcomponente.empresa = v_empresa
                            AND pcpopcomponente.op = Nvl(v_op_principal, v_op)
                            AND Nvl(pcpopcomponente.etapa_aplicacao, v_etapa) = v_etapa
                            AND pcpopcomponente.empresa = estitem.empresa
                            AND pcpopcomponente.componente = estitem.codigo
                            AND estitem.tipo_item in (11,33)
                     ORDER  BY pcpopcomponente.seq_aplicacao) LOOP
          v_desc_comp := v_desc_comp
                         ||' '
                         ||r_comp.componente;

          v_qtde_comp := v_qtde_comp + 1;
      END LOOP;

      v_prompt := 'C:';

      SELECT Max(valor_padrao)
      INTO   v_atributo
      FROM   pcpficcargarec
      WHERE  empresa = v_empresa
             AND class_carga_recurso = v_produto
             AND etapa = v_etapa
             AND recurso = v_recurso
             AND atributo = 5081;

      IF v_atributo IS NULL THEN
        v_atributo := F_busca_valor_ficha(v_empresa, v_produto, v_versao, NULL,24);
      END IF;

      v_prompt2 := 'G:';

      SELECT Max(valor_padrao)
      INTO   v_atributo2
      FROM   pcpficcargarec
      WHERE  empresa = v_empresa
             AND class_carga_recurso = v_produto
             AND etapa = v_etapa
             AND recurso = v_recurso
             AND atributo = 5082;

      IF v_atributo2 IS NULL THEN
        v_atributo2 := F_busca_valor_ficha(v_empresa, v_produto, v_versao, NULL,950);
      END IF;

      v_prompt4 := 'Obs:';

      SELECT Max(valor_padrao)
      INTO   v_atributo4
      FROM   pcpficcargarec
      WHERE  empresa = v_empresa
             AND class_carga_recurso = v_produto
             AND etapa = v_etapa
             AND recurso = v_recurso
             AND atributo = 5083;

      IF v_atributo4 IS NULL THEN
        v_atributo4 := F_busca_valor_ficha(v_empresa, v_produto, v_versao, NULL,68);
      END IF;
      
    ELSIF v_etapa = 70 THEN
      v_prompt5 := ' PREVISÃO ENTREGA:';

      SELECT Max(compedit.previsao_ent)
      INTO   v_previsao
      FROM   compedit,
             comped
      WHERE  compedit.empresa = v_empresa
             AND compedit.empresa = comped.empresa
             AND compedit.pedido = comped.pedido
             AND comped.data_faturamento IS NOT NULL
             AND compedit.op = v_op;

      SELECT Nvl(Max(observacao), '+AA+')
      INTO   v_observacao
      FROM   pcpoprecurso
      WHERE  empresa = v_empresa
             AND op = v_op
             AND etapa = v_etapa
             AND recurso = v_recurso;

      SELECT Nvl(SUM(qtd_entrada), 0)
      INTO   v_qtde_item
      FROM   compedit
      WHERE  empresa = v_empresa
             AND op = v_op;
    ELSE
      v_atributo := NULL;
      v_prompt := '';
      v_atributo2 := NULL;
      v_prompt2 := '';
      v_atributo4 := NULL;
      v_prompt4 := '';
      v_previsao := NULL;
      v_prompt5 := '';
      v_prompt6 := '';
      
    END IF;

    IF v_etapa = 20 THEN
      --Buscar bobinas filhas
      SELECT Count(1)
      INTO   v_bobinas
      FROM   pcpapproducao
      WHERE  empresa = v_empresa
             AND etapa IN ( 10, 11, 70 )
             AND op = v_op;

      SELECT Max(Decode(pcpetapa.tempo_recursos, 'H',
                 pcpcaprecurso.tempo_acerto / 60,
                                                 pcpcaprecurso.tempo_acerto))
      INTO   v_acerto_anterior
      FROM   pcpcaprecurso,
             pcpetapa
      WHERE  pcpetapa.empresa = pcpcaprecurso.empresa
             AND pcpetapa.codigo = pcpcaprecurso.etapa
             AND pcpcaprecurso.empresa = v_empresa
             AND pcpcaprecurso.etapa = v_etapa
             AND pcpcaprecurso.recurso = v_recurso
             AND pcpcaprecurso.class_carga_recurso = v_produto;
    END IF;

    IF v_etapa IN ( 10, 11 ) THEN
      v_tipo_solda := F_busca_valor_ficha(v_empresa, v_produto, v_versao, NULL,6);
    END IF;

    IF v_qtde_comp > 0 THEN
      v_retorno := Rtrim(v_retorno)
                   || 'Cs:'
                   || v_qtde_comp
                   ||' '
                   ||v_desc_comp;
    END IF;

    IF v_atributo IS NOT NULL THEN
      v_retorno := v_retorno
                   ||' /  '
                   || Rtrim(v_prompt)
                   || ' '
                   || Rtrim(v_atributo);
    END IF;

    IF v_atributo2 IS NOT NULL THEN
      v_retorno := Rtrim(v_retorno)
                   || ' /  '
                   || Rtrim(v_prompt2)
                   || ' '
                   || Rtrim(v_atributo2);
    END IF;

    IF v_tipo_solda IS NOT NULL THEN
      v_retorno := Rtrim(v_tipo_solda);
    END IF;

    IF v_descPigmento IS NOT NULL THEN
      v_retorno := Rtrim(v_retorno)
                   || ' / '
                   || Rtrim(v_descPigmento);
    END IF;

    IF v_atributo4 IS NOT NULL AND v_etapa = 20 THEN
      v_retorno := Rtrim(v_retorno)
                   || ' / '
                   || Rtrim(v_atributo4);
    END IF;

    IF v_bobinas > 0 THEN
      v_retorno := v_retorno
                   ||' / Bobinas: '
                   ||v_bobinas;
    END IF;

    IF v_acerto_anterior > 0 THEN
      v_retorno := v_retorno
                   ||' / Acto Ant(min): '
                   ||v_acerto_anterior;
    END IF;

    IF v_previsao IS NOT NULL
       AND v_etapa = 70 THEN
      v_retorno := Rtrim(v_prompt5)
                   ||' '
                   || Rtrim(v_previsao)
                   ||' - Qtde Entregue: '
                   ||v_qtde_item;
    END IF;

    IF v_observacao NOT IN ( '+AA+' ) AND v_etapa = 70 THEN
      UPDATE pcpoprecurso
      SET    observacao = v_observacao
      WHERE  empresa = v_empresa
             AND op = v_op
             AND etapa = v_etapa
             AND recurso = v_recurso;
    END IF;

    IF (v_evoh > 0 OR v_comp_affinity > 0) AND v_etapa IN ( 10, 11, 12 ) THEN
      v_retorno := Rtrim(v_retorno) || ' / ' || Rtrim(v_prompt6);
    END IF;

    IF v_prompt8 IS NOT NULL AND v_recurso BETWEEN 210 AND 298 THEN
      v_retorno := Rtrim(v_retorno) || ' / Loc. Acessorio: ' ||v_prompt8;
    END IF;

    IF v_etapa IN ( 30, 31, 32, 33, 34, 35 ) THEN
      SELECT Max(valor_padrao)
      INTO   v_atributo10
      FROM   pcpficha
      WHERE  empresa = v_empresa
             AND produto = v_produto_filho
             AND versao = v_versao_filho
             AND atributo = 123;
    END IF;

    IF v_etapa < 20 THEN
      :p_5 := v_retorno
              ||v_pig
              ||' COMPOSICAO: '
              ||v_composicao;

    ELSE
      :p_5 := v_retorno
              ||v_pig
              ||' COMPOSICAO: '
              ||v_composicao
              ||' LARG. EMB: '
              ||v_atributo10;
    END IF;

    IF v_qtde_aditivo > 0 THEN
      :p_5 := v_retorno
              ||' '
              ||v_desc_aditivo;
    END IF;

    --dbms_output.Put_line(v_p5);
    
EXCEPTION
    WHEN OTHERS THEN
      :p_5 := SQLERRM;
      
END;
