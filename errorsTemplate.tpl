{{ range .Errors }}
{{ if .HasComment }}{{ .Comment }}{{ end -}}
func IsError{{.CamelValue}}(err error) bool {
	if err == nil {
		return false
	}
	e := errors.FromError(err)
	return e.Reason == {{ .Name }}_{{ .Value }}.String() && e.Code == {{ .HTTPCode }}
}

{{ if .HasComment }}{{ .Comment }}{{ end -}}
func Error{{ .CamelValue }}WithCustomMessage(format string, args ...interface{}) *errors.Error {
	return errors.New({{ .HTTPCode }}, {{ .Name }}_{{ .Value }}.String(), fmt.Sprintf(format, args...))
}

{{ if .HasComment }}{{ .Comment }}{{ end -}}
{{ if .HasMessageArgument }}
func Error{{ .CamelValue }}(args ...interface{}) *errors.Error {
	return errors.New({{ .HTTPCode }}, {{ .Name }}_{{ .Value }}.String(), fmt.Sprintf("{{ .Message }}", args...))
}
{{ else }}
func Error{{ .CamelValue }}() *errors.Error {
	return errors.New({{ .HTTPCode }}, {{ .Name }}_{{ .Value }}.String(), "{{ .Message }}")
}
{{ end -}}

{{- end }}
