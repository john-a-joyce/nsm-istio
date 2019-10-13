apiVersion: apps/v1
kind: Deployment
metadata:
  name: nsm-svc-reg
  namespace: {{ .Release.Namespace }}
spec:
  selector:
    matchLabels:
      run: nsm-svc-reg
  replicas: 1
  template:
    metadata:
      labels:
        run: nsm-svc-reg
      annotations:
        sidecar.istio.io/inject: "false"
    spec:
      containers:
        - name: nsm-svc-reg
          image: {{ .Values.registry }}/{{ .Values.org }}/nsm_svc_reg:{{ .Values.tag }}
          imagePullPolicy: {{ .Values.pullPolicy }}
          command: [ "/usr/bin/nsm_svc_reg", "pod-watcher" ]
          args: [ "--kubeconfig", "/etc/watch/kubeconfig", "--kubeconfigremote", "/etc/svcreg/kubeconfig", "-a", "$(NAMESPACE)" ]
          env:
          - name: NAMESPACE
            value: {{ .Values.watchNamespace }}
          volumeMounts:
          - name: svcregclusterdata
            mountPath: "/etc/svcreg"
            readOnly: true
          - name: watchclusterdata
            mountPath: "/etc/watch"
            readOnly: true
      volumes:
      - name: svcregclusterdata
        secret:
          secretName: {{ .Values.svcRegKubeConfigSecret }}
      - name: watchclusterdata
        secret:
          secretName: {{ .Values.watchKubeConfigSecret }}
