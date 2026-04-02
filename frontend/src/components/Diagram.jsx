import { FaServer, FaDatabase, FaCloud } from "react-icons/fa";

/* ---------- NODE ---------- */
function Node({ label, children }) {
  return (
    <div className="flex flex-col items-center gap-2">
      <div className="relative p-4 rounded-xl border border-zinc-700 bg-black">

        {/* Пульс */}
        <div className="absolute inset-0 rounded-xl bg-green-500 opacity-10 animate-ping"></div>

        {children}
      </div>

      <span className="text-sm text-gray-300">{label}</span>
    </div>
  );
}

/* ---------- FLOW LINE ---------- */
function FlowLine() {
  return (
    <div className="relative w-24 h-[2px] bg-zinc-700 overflow-hidden rounded">
      <div className="absolute w-6 h-[2px] bg-green-400 animate-flow"></div>
    </div>
  );
}

/* ---------- MAIN DIAGRAM ---------- */
export default function Diagram({ data }) {
  return (
    <div className="text-white mt-10 space-y-8">

      {/* AWS CLOUD */}
      <div className="border border-blue-500 rounded-2xl p-6">
        <h2 className="text-lg font-bold mb-6 flex items-center gap-2">
          <FaCloud /> AWS Cloud
        </h2>

        {/* VPC */}
        <div className="border border-purple-500 rounded-xl p-6 space-y-6">
          <p className="text-sm text-purple-300">VPC (10.0.0.0/16)</p>

          {/* TRAFFIC FLOW */}
          <div className="flex items-center justify-center gap-4">

            <Node label="Internet">
              🌐
            </Node>

            <FlowLine />

            <Node label="ALB">
              <FaServer />
            </Node>

            <FlowLine />

            <Node label={`EC2 (${data?.ec2?.count || 2})`}>
              <FaServer />
            </Node>

            <FlowLine />

            <Node label="RDS">
              <FaDatabase />
            </Node>

          </div>

          {/* AZ */}
          <div className="grid grid-cols-2 gap-6 mt-6">

            {/* AZ A */}
            <div className="border border-gray-700 rounded-xl p-4">
              <p className="text-xs text-gray-400 mb-2">AZ A</p>

              <div className="space-y-3">
                <div className="text-xs text-green-400">Public</div>
                <div className="text-xs text-blue-400">Private</div>
              </div>
            </div>

            {/* AZ B */}
            <div className="border border-gray-700 rounded-xl p-4">
              <p className="text-xs text-gray-400 mb-2">AZ B</p>

              <div className="space-y-3">
                <div className="text-xs text-green-400">Public</div>
                <div className="text-xs text-blue-400">Private</div>
              </div>
            </div>

          </div>

        </div>
      </div>
    </div>
  );
}