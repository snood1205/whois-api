CREATE TABLE domains (
	id SERIAL PRIMARY KEY,
	creation_date TIMESTAMPTZ NOT NULL,
	domain VARCHAR(255) UNIQUE NOT NULL,
	expiration_date TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_domains_domain ON domains(domain);

CREATE TABLE api_keys (
	id SERIAL PRIMARY KEY,
	api_key TEXT NOT NULL UNIQUE,
	email TEXT NOT NULL UNIQUE,
	email_verified BOOLEAN DEFAULT FALSE,
	validation_code TEXT
);

CREATE INDEX idx_api_keys_api_key ON api_keys(api_key);

CREATE TABLE requests (
	id SERIAL PRIMARY KEY,
	api_key_id INTEGER NOT NULL,
	time TIMESTAMPTZ DEFAULT NOW(),
	FOREIGN KEY (api_key_id) REFERENCES api_keys(id) ON DELETE CASCADE
);

CREATE INDEX idx_requests_time ON requests(time);
CREATE INDEX idx_requests_api_key_id ON requests(api_key_id);
