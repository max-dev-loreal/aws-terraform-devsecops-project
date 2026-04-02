export default function AwsIcon({ type }) {
  const icons = {
    alb: "🟠",
    ec2: "🟦",
    rds: "🟣",
    internet: "🌐"
  };

  return (
    <div className="text-2xl">
      {icons[type] || "⬜"}
    </div>
  );
}