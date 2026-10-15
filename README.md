# Uzak Ollama sunucusu

Bu klasör, `hadad/qwen3-4bd:Q8_0` modelini Docker içinde çalıştırır. Model bu repoya dahil değildir ve kurulumu yaptığınız bilgisayarda ilk açılışta indirilir. Ollama portu doğrudan yayımlanmaz; istekler bir API anahtarı kontrolünden geçer.

Model yaklaşık **4,3 GB** indirme alanı kullanır. Docker verileri kalıcı bir volume içinde saklandığı için konteyner yeniden oluşturulunca tekrar indirilmez. Q8_0 sürümü, 16 GB RAM ve Ryzen 5 3600 bulunan hedef bilgisayar için BF16 sürümünden daha uygundur; GPU kullanılamazsa CPU üzerinde de çalışır.

## 1. Hedef bilgisayara taşıma

Bu klasörü Git ile hedef bilgisayara klonlayın veya yalnızca `ollama-remote-server` klasörünü kopyalayın. Hedefte Docker Desktop (Windows/macOS) ya da Docker Engine + Compose (Linux) kurulu olmalıdır.

Windows PowerShell:

```powershell
cd ollama-remote-server
.\setup.ps1
```

Linux/macOS:

```sh
cd ollama-remote-server
chmod +x setup.sh
./setup.sh
```

Bu işlem 64 karakterli rastgele bir API anahtarı üretip `.env` dosyasına yazar. API anahtarı, yalnızca anahtarı bilen istemcilerin modele istek gönderebilmesini sağlayan gizli paroladır. `.env` Git'e eklenmez ve başkalarıyla paylaşılmamalıdır.

## 2. Çalıştırma

### CPU ile veya otomatik donanım algılamasıyla

```sh
docker compose -f compose.yml -f compose.lan.yml up -d
```

### NVIDIA ekran kartıyla

NVIDIA sürücüsü ve NVIDIA Container Toolkit/Docker Desktop GPU desteği gerekir:

```sh
docker compose -f compose.yml -f compose.lan.yml -f compose.nvidia.yml up -d
```

İlk çalıştırma yaklaşık 4,3 GB modeli hedef bilgisayara indirir. İlerlemeyi görmek için:

```sh
docker compose -f compose.yml -f compose.lan.yml logs -f model-pull
```

`model-pull exited with code 0` görüldüğünde sunucu hazırdır.

## 3. Başka bilgisayardan kullanma

Sunucu bilgisayarın yerel IP'sini bulun (örnek: `192.168.1.50`) ve `.env` içindeki `API_KEY` değerini kullanın:

```sh
curl http://192.168.1.50:11434/api/chat \
  -H "Authorization: Bearer API_ANAHTARINIZ" \
  -H "Content-Type: application/json" \
  -d '{"model":"hadad/qwen3-4bd:Q8_0","messages":[{"role":"user","content":"Merhaba!"}],"stream":false}'
```

OpenAI uyumlu istemciler için temel adres:

```text
http://192.168.1.50:11434/v1
```

OpenAI SDK örneği:

```js
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "http://192.168.1.50:11434/v1",
  apiKey: process.env.OLLAMA_API_KEY,
});

const result = await client.chat.completions.create({
  model: "hadad/qwen3-4bd:Q8_0",
  messages: [{ role: "user", content: "Merhaba!" }],
});

console.log(result.choices[0].message.content);
```

Windows Güvenlik Duvarı'nda TCP `11434` portuna izin verin. Aynı ağdan `http://SUNUCU-YEREL-IP:11434` adresi kullanılır. Dışarıdan erişim için en güvenli seçenek Tailscale/WireGuard kurup aynı adresi sunucunun VPN IP'siyle kullanmaktır.

Modem üzerinden doğrudan açmak isterseniz TCP `11434` portunu sunucu bilgisayarın yerel IP'sine yönlendirin ve `http://GENEL-IP:11434` adresini kullanın. Bu yöntem HTTP kullandığı için API anahtarı ağ üzerinde şifrelenmez; güvenilmeyen ağlarda VPN tercih edin. İnternet servis sağlayıcınız CGNAT kullanıyorsa modem port yönlendirmesi çalışmaz, fakat Tailscale çalışır.

## Yönetim

```sh
# Durum
docker compose -f compose.yml -f compose.lan.yml ps

# Durdur
docker compose -f compose.yml -f compose.lan.yml down

# Model verisi dahil her şeyi sil (geri alınamaz)
docker compose -f compose.yml -f compose.lan.yml down -v
```

Modeli değiştirmek için `.env` içindeki `MODEL_NAME` değerini düzenleyip tekrar `up -d` çalıştırın.

