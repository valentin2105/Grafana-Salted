{%- set hostname = salt['grains.get']('host') -%}
{%- set hostname_apps_dict = hostname, "_apps" -%}
{%- set hostname_apps = (hostname_apps_dict|join) -%}

{%- set influxdb_version = pillar[hostname_apps]['grafana']['influxdb']['version'] -%}
{%- set grafana_version = pillar[hostname_apps]['grafana']['grafana']['version'] -%}

/var/cache/apt/{{ influxdb_version }}.deb:
  file.managed:
     - source: salt://grafana/{{ influxdb_version }}.deb

{{ influxdb_version }}:
  module.run:
     - name: pkg.install
     - sources:
       - {{ influxdb_version }}: /var/cache/apt/{{ influxdb_version }}.deb

/etc/opt/influxdb/influxdb.conf:
  file:
  - managed
  - source: salt://grafana/influxdb.conf
  - user: root
  - group: root
  - mode: 644
  - template: jinja

influxdb:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: /etc/opt/influxdb/influxdb.conf


/var/cache/apt/{{ grafana_version }}.deb:
  file.managed:
     - source: salt://grafana/{{ grafana_version }}.deb

{{ grafana_version }}:
  module.run:
     - name: pkg.install
     - sources:
       - {{ grafana_version }}: /var/cache/apt/{{ grafana_version }}.deb

/etc/grafana/grafana.ini:
  file:
  - managed
  - source: salt://grafana/grafana.ini
  - user: root
  - group: root
  - mode: 644
  - template: jinja

grafana-server:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: /etc/grafana/grafana.ini
