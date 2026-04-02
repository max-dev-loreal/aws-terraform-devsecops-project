import { useEffect, useState } from "react";
import { mockData } from "../mock/data";
import Diagram from "../components/Diagram";

export default function Dashboard() {
  const [data, setData] = useState(null);

  useEffect(() => {
    // 1. Инициализируем данные при загрузке
    setData(mockData);

    // 2. Устанавливаем интервал для имитации скейлинга
    const interval = setInterval(() => {
      setData((prev) => {
        if (!prev) return prev;
        return {
          ...prev,
          ec2: {
            ...prev.ec2,
            count: prev.ec2.count === 2 ? 3 : 2,
          },
        };
      });
    }, 3000);

    // 3. Очищаем интервал при размонтировании компонента
    return () => clearInterval(interval);
  }, []); // Пустой массив зависимостей — сработает один раз при старте

  if (!data) {
    return (
      <div className="h-screen flex items-center justify-center bg-black text-white">
        Loading infrastructure...
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-black text-white p-6">
      <h1 className="text-3xl font-bold mb-10">AWS Infrastructure Dashboard</h1>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card
          title="EC2 Instances"
          value={data.ec2.count}
          status={data.ec2.status}
        />
        <Card title="Desired Capacity" value={data.ec2.desired} />
        <Card title="RDS" value={data.rds.status} status="green" />
        <Card title="ALB" value={data.alb.status} status="green" />
      </div>

      <div className="mt-10">
        <Diagram data={data} />
      </div>
    </div>
  );
}

function Card({ title, value, status }) {
  return (
    <div className="bg-zinc-900 p-6 rounded-2xl shadow-lg border border-zinc-800">
      <h2 className="text-gray-400">{title}</h2>
      <div className="flex items-center justify-between mt-3">
        <p className="text-2xl font-semibold">{value}</p>
        {status && (
          <span className="w-3 h-3 rounded-full bg-green-500 animate-ping"></span>
        )}
      </div>
    </div>
  );
}