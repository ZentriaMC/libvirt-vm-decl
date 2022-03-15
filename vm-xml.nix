{ libxml2, python3, runCommandNoCC }:

{ name
, uuid ? null
, memory ? 1073740000 # 1 GiB
, nic
, mac
}@args:

runCommandNoCC "libvirt-decl-${name}.xml"
{
  definitionArgs = builtins.toJSON args;
  xmlTemplate = ''
    <domain type="kvm">
      <name>${name}</name>
      <uuid><![CDATA[@UUID_TEMPLATE@]]></uuid>
      <os>
        <type>hvm</type>
      </os>
      <memory unit="b">${toString memory}</memory>
      <devices>
        <disk type="volume">
          <source volume="guest-${name}"/>
          <target dev="vda" bus="virtio"/>
        </disk>
        <graphics type="spice" autoport="yes"/>
        <input type="keyboard" bus="usb"/>
        <interface type="direct">
          <source dev="${nic}" mode="bridge"/>
          <mac address="${mac}"/>
          <model type="virtio"/>
        </interface>
      </devices>
      <features>
        <acpi/>
      </features>
    </domain>
  '';

  passAsFile = [
    "definitionArgs"
    "xmlTemplate"
  ];

  nativeBuildInputs = [
    libxml2.bin
    python3
  ];

  checkPhase = ''
    runHook preCheck

    xmllint --noout $out

    runHook postCheck
  '';
}
  (
    (if uuid == null then ''
      # generate UUID v5 from input - null domain and sha1 of the arguments, works fine enough
      uuid="$(python3 -c 'import json, sys, uuid; sys.stdout.write(str(uuid.uuid5(uuid.UUID(bytes=b"\x00" * 16), input())))' < $definitionArgsPath)"
      echo "generated uuid $uuid for vm ${name}"
    '' else ''
      uuid='${uuid}'
    '') + ''
      # TODO: substituteStream does not work
      cat $xmlTemplatePath | sed "s|@UUID_TEMPLATE@|$uuid|g" | xmllint - > $out
    ''
  )
