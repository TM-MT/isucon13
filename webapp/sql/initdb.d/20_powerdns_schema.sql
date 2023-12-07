use isudns;

CREATE INDEX records_domain_id_name ON isudns.records(domain_id,name);
